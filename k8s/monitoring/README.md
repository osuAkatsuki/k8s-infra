# Self-Hosted Monitoring Stack

Replaces Grafana Cloud with self-hosted Loki + Mimir + Grafana, using Wasabi S3 for storage.

## Prerequisites

### 1. Create Wasabi Buckets

In Wasabi console (ca-central-1 region):
- `akatsuki-loki` — for logs
- `akatsuki-mimir` — for metrics

### 2. Add GitHub Secrets

Add these secrets to the repository:

```
WASABI_ACCESS_KEY     — Wasabi access key
WASABI_SECRET_KEY     — Wasabi secret key
GRAFANA_ADMIN_PASSWORD — Password for Grafana admin user
```

### 3. DNS Setup

Point `grafana.akatsuki.gg` to your ingress controller's external IP.

## Deployment

Push to master or trigger workflow manually:

```bash
gh workflow run monitoring.yml
```

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Alloy     │────▶│    Loki     │────▶│   Wasabi    │
│  (collector)│     │  (logs)     │     │  S3 Bucket  │
│             │────▶│    Mimir    │────▶│             │
└─────────────┘     │  (metrics)  │     └─────────────┘
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │   Grafana   │
                    │ (dashboards)│
                    └─────────────┘
```

## Transition from Grafana Cloud

The Alloy config sends data to BOTH local and Grafana Cloud during transition.

### After 30 days, remove Grafana Cloud:

1. Edit `alloy-values.yaml`:
   - Remove `loki.write "cloud"` block
   - Remove `prometheus.remote_write "cloud"` block
   - Update `forward_to` arrays to only include `.local.receiver`

2. Remove cloud secrets from GitHub (optional):
   - `PROMETHEUS_USER`
   - `GRAFANA_USER`
   - `GRAFANA_SECRET`

3. Cancel Grafana Cloud subscription

## Accessing Grafana

URL: https://grafana.akatsuki.gg
User: admin
Password: (value of GRAFANA_ADMIN_PASSWORD secret)

## Resource Usage

| Component | CPU | Memory | Storage |
|-----------|-----|--------|---------|
| Loki | 100-500m | 256-512Mi | Wasabi S3 |
| Mimir | 100-1000m | 512Mi-1Gi | 10Gi PVC + Wasabi S3 |
| Grafana | 100-500m | 128-256Mi | 1Gi PVC |
| Alloy | ~100m | ~200Mi | — |

## Troubleshooting

### Check pod status
```bash
kubectl -n monitoring get pods
```

### Check Loki logs
```bash
kubectl -n monitoring logs -l app.kubernetes.io/name=loki
```

### Check Mimir logs
```bash
kubectl -n monitoring logs -l app.kubernetes.io/name=mimir
```

### Test Loki ingestion
```bash
kubectl -n monitoring port-forward svc/loki 3100:3100
curl -X POST "http://localhost:3100/loki/api/v1/push" \
  -H "Content-Type: application/json" \
  -d '{"streams":[{"stream":{"test":"true"},"values":[["'$(date +%s)000000000'","test log"]]}]}'
```
