# phpMyAdmin

Simple phpMyAdmin deployment using the official image.

## Deploy

```bash
kubectl apply -f k8s/phpmyadmin/deployment.yaml
```

## Configuration

Environment variables in `deployment.yaml`:
- `PMA_HOST`: MySQL server address (VPC internal IP: 10.118.0.4)
- `PMA_PORT`: MySQL port (3306)
- `PMA_ARBITRARY`: Allow connecting to any MySQL server (1 = enabled)

## Access

phpMyAdmin is exposed via the k8s-rev-proxy nginx configuration.

For local access via port-forward:
```bash
kubectl port-forward svc/phpmyadmin 8080:80
```
Then open http://localhost:8080

## Notes

Previously used Bitnami Helm chart, but Bitnami moved to paid subscriptions
in August 2025. Migrated to official `phpmyadmin/phpmyadmin` image.
