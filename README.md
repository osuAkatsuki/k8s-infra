# k8s-infra

Infrastructure-as-code for the Akatsuki Kubernetes cluster on DigitalOcean.

## Cluster Overview

| Node         | Role          | Public IP       | VPC IP     | Notes                       |
|--------------|---------------|-----------------|------------|-----------------------------|
| k8s-master01 | Control plane | 159.203.62.14   | 10.118.0.2 | Runs control plane components |
| k8s-worker01 | Worker        | 138.197.146.243 | 10.118.0.3 | Workload node               |
| k8s-worker02 | Worker        | 68.183.194.110  | 10.118.0.7 | Workload node               |

**VPC**: 10.118.0.0/20 (DigitalOcean TOR1)

## Repository Structure

```
k8s-infra/
├── .github/workflows/     # CI/CD pipelines
│   └── grafana.yml        # Grafana k8s-monitoring deployment
├── k8s/                   # Kubernetes manifests
│   ├── flannel/           # CNI configuration
│   ├── github-runner/     # Self-hosted GitHub Actions runner (ARC)
│   ├── istio/             # Service mesh telemetry
│   ├── rbac/              # RBAC rules
│   ├── datadog-agent.yaml # Datadog monitoring
│   ├── grafana-*.yaml     # Grafana stack configs
│   └── metrics-server.yml # Metrics server
├── nodes/                 # Node-specific configs
│   └── kubelet-config/    # Kubelet flags per node
└── tf/                    # Terraform configs
    ├── cloudflare.tf      # DNS and CDN
    ├── digitalocean.tf    # Droplets and firewalls
    └── provider.tf        # Provider configuration
```

## Networking

- **Pod CIDR**: 10.244.0.0/16 (Flannel)
- **Service CIDR**: 10.96.0.0/12
- **CNI**: Flannel with VXLAN backend over VPC (eth1)

All inter-node traffic (kubelet, flannel VXLAN) uses VPC IPs to avoid public bandwidth costs.

## Quick Reference

### Terraform

```bash
cd tf/
terraform init
terraform plan
terraform apply
```

### Kubectl

```bash
# Get cluster status
kubectl get nodes -o wide
kubectl get pods -A

# Check flannel
kubectl get pods -n kube-flannel
```

### SSH Access

Nodes are accessible via SSH config aliases:
```bash
ssh k8s-master01
ssh k8s-worker01
ssh k8s-worker02
```

## CI/CD

- **Grafana workflow**: Deploys k8s-monitoring stack on push to master
- **Terraform CI**: Validates and applies infrastructure changes
- **Self-hosted runner**: Runs in VPC for secure K8s API access (see `k8s/github-runner/`)

## Related Repositories

- Service deployments are managed in separate application repositories
- Helm charts use values files in this repo (e.g., `grafana-k8s-monitor.yaml`)
