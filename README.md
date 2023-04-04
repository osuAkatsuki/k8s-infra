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
