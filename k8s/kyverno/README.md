# Kyverno

Policy engine for Kubernetes that validates, mutates, and generates resources.

## Installation

```bash
# Add Helm repo
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update kyverno

# Install Kyverno
helm install kyverno kyverno/kyverno \
  -n kyverno \
  --create-namespace \
  -f values.yaml \
  --wait

# Apply policies
kubectl apply -f policies/
```

## Upgrade

```bash
helm repo update kyverno
helm upgrade kyverno kyverno/kyverno \
  -n kyverno \
  -f values.yaml \
  --wait
```

## Uninstall

```bash
kubectl delete -f policies/
helm uninstall kyverno -n kyverno
kubectl delete ns kyverno
```

## Policies

| Policy | Mode | Description |
|--------|------|-------------|
| `restrict-image-registries` | Enforce | Only allow images from approved registries |
| `require-resource-limits` | Enforce | Block pods without resource limits |
| `disallow-privileged-containers` | Enforce | Block privileged containers |
| `require-probes` | Enforce | Block web services without readiness probes |

### Exclusions

The following are excluded from resource limits and probe requirements:
- System namespaces: `kube-system`, `kyverno`, `kube-flannel`, `grafana`
- CronJob pods (identified by `job-name` label)
- GitHub runner namespace
- Background workers: `*-discord-bot-*`, `*-pubsub-daemon-*`, `*-amqp-processor-*`, `*-processor-production-*`

## Checking Policy Violations

```bash
# View policy reports
kubectl get policyreport -A

# View cluster-wide policy reports
kubectl get clusterpolicyreport

# Describe a specific report for details
kubectl describe policyreport -n default
```
