#!/usr/bin/env bash
set -eo pipefail

read -p "Environment: " environment
if [ "$environment" != "staging" ] && [ "$environment" != "production" ]; then
    echo "Invalid environment: $environment"
    exit 1
fi

# Provision shared infra components
cd shared/tf
terraform init
terraform plan -out tplan
terraform apply tplan
cd ../..

# Provision environment-specific infra components
cd $environment/tf
terraform init
terraform plan -out tplan
terraform apply tplan
cd ../..

# Install nginx-ingress-controller
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
helm install nginx-ingress nginx-stable/nginx-ingress

# Install vault
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault

# Setup vault-agent for k8s auth
kubectl exec -it vault-0 -- sh -c ' \
    vault login && \
    vault auth enable kubernetes && \
    vault write auth/kubernetes/config kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"'

# Add kubernetes auth policies for each service
services=(
    users-service
    akatsuki-api
    hanayo
)
for service in "${services[@]}"
do
    kubectl exec -i vault-0 -- vault policy write $service-$environment - <<EOF
path "services/data/$environment/$service" {
capabilities = ["read"]
}
EOF

    kubectl exec -it vault-0 -- vault write auth/kubernetes/role/$service-$environment \
        bound_service_account_names=$service-$environment \
        bound_service_account_namespaces=default \
        policies=$service-$environment \
        ttl=24h

    kubectl create serviceaccount $service-$environment
done

# Add userpass auth policies for each staff member
staff_members=(
    "josh"
    "james"
    "lenforiee"
    "flame"
)
for staff_member in "${staff_members[@]}"
do
    kubectl exec -it vault-0 -- vault policy write $staff_member-$environment - <<EOF
path "services/data/$environment/*" {
capabilities = ["read"]
}
EOF

    kubectl exec -it vault-0 -- vault write auth/userpass/users/$staff_member-$environment \
        password=$staff_member-$environment \
        policies=$staff_member-$environment
done

# Setup datadog-agent
helm repo add datadog https://helm.datadoghq.com
helm install datadog-agent-$environment -f datadog-values.yaml \
  --set datadog.site='datadoghq.com' \
  --set datadog.apiKey=$YOUR_DATADOG_API_KEY \
  datadog/datadog

# Configure ingress
kubectl apply -f k8s/ingress.yaml

# # TODO: setup instructions for our vpn (running algo)
# https://zeltser.com/deploy-algo-vpn-digital-ocean/

# Import database
if [ -n "akatsuki.sql" ]; then
    echo "importing akatsuki.sql"

    echo -n "DB host: "
    read -s db_host

    echo -n "DB port: "
    read -s db_port

    echo -n "DB user: "
    read -s db_user

    echo -n "DB pass: "
    read -s db_pass

    db_name="akatsuki"

    mysql -h $db_host -P $db_port -u $db_user -p$db_pass -e "CREATE DATABASE $db_name;"
    # create read & write users for each service
    for service in "${services[@]}"
    do
        read_user_name="${service/-/_}_read"
        read_user_pass=`python3 -c 'print(__import__("secrets").token_hex(16), end="")'`
        mysql -h $db_host -P $db_port -u $db_user -p$db_pass -e "CREATE USER '$read_user_name'@'%' IDENTIFIED BY '$read_user_pass';"
        mysql -h $db_host -P $db_port -u $db_user -p$db_pass -e "GRANT SELECT ON $db_name.* TO '$read_user_name'@'%';"
        echo "$read_user_name with password $read_user_pass" >> db_accounts.txt

        write_user_name="${service/-/_}_write"
        write_user_pass=`python3 -c 'print(__import__("secrets").token_hex(16), end="")'`
        mysql -h $db_host -P $db_port -u $db_user -p$db_pass -e "CREATE USER '$write_user_name'@'%' IDENTIFIED BY '$write_user_pass';"
        mysql -h $db_host -P $db_port -u $db_user -p$db_pass -e "GRANT INSERT, UPDATE, DELETE ON $db_name.* TO '$write_user_name'@'%';"
        echo "$write_user_name with password $write_user_pass" >> db_accounts.txt
    done
    mysql -h $db_host -P $db_port -u $db_user -p$db_pass $db_name < akatsuki.sql
else
    echo "skipping akatsuki.sql import (not found)"
fi
