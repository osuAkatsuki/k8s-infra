# GitHub Actions Self-Hosted Runner

Lightweight Helm chart for a single self-hosted runner in the VPC.

## Setup

```bash
# Create namespace and PAT secret
kubectl create namespace github-runner
kubectl create secret generic github-runner \
  --namespace github-runner \
  --from-literal=token=ghp_YOUR_TOKEN_HERE

# Install chart
helm install github-runner ./k8s/github-runner --namespace github-runner
```

## Verify

```bash
kubectl get pods -n github-runner
kubectl logs -n github-runner -l app=github-runner
```

Runner appears at: https://github.com/organizations/osuAkatsuki/settings/actions/runners

## Usage

```yaml
jobs:
  deploy:
    runs-on: [self-hosted, vpc]
```

## Upgrade

```bash
helm upgrade github-runner ./k8s/github-runner --namespace github-runner
```
