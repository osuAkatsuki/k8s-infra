# Infrastructure for the k8s model

# Setting up infrastructure

## Apply shared infra components
```sh
# Provision infra
cd shared/tf
tf init
tf plan -out tplan
tf apply tplan

# Install nginx-ingress-controller
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
helm install nginx-ingress nginx-stable/nginx-ingress

# Install vault
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault

# Setup vault-agent for k8s auth
kubectl exec -it vault-0 /bin/sh
vault login
vault auth enable kubernetes
vault write auth/kubernetes/config kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"
exit

# Setup datadog-agent
helm repo add datadog https://helm.datadoghq.com
helm install datadog-agent-staging -f datadog-values.yaml \
  --set datadog.site='datadoghq.com' \
  --set datadog.apiKey=$YOUR_DATADOG_API_KEY \
  datadog/datadog
```

## Apply a specific environment's components
```sh
cd staging # or production

# Provision infra
cd tf
tf init
tf plan -out tplan
tf apply tplan
cd ..

# Configure ingress
kubectl apply -f k8s/ingress.yaml

# TODO: documentation for setting up algo
# https://zeltser.com/deploy-algo-vpn-digital-ocean/
```

## Adding vault injection for a service
This should likely be done automatically; just not sure where yet.
```sh
kubectl exec -it vault-0 -- /bin/sh

vault policy write users-service-staging - <<EOF
path "services/data/staging/users-service" {
  capabilities = ["read"]
}
EOF

vault write auth/kubernetes/role/users-service-staging \
    bound_service_account_names=users-service-staging \
    bound_service_account_namespaces=default \
    policies=users-service-staging \
    ttl=24h

exit

kubectl create serviceaccount users-service-staging
