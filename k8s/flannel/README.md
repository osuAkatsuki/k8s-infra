# Flannel CNI

Flannel provides the pod network overlay using VXLAN.

## Current State

- **Version**: v0.23.0
- **Backend**: VXLAN (UDP port 8472)
- **Pod CIDR**: 10.244.0.0/16
- **Interface**: eth1 (VPC interface on DigitalOcean)

### Node VXLAN IPs

Flannel uses `--iface=eth1` to bind to the VPC interface, and the
`flannel.alpha.coreos.com/public-ip` annotation tells other nodes which IP to use
for VXLAN tunnels to this node.

| Node | VXLAN IP | Interface | Status |
|------|----------|-----------|--------|
| k8s-master01 | 10.118.0.2 | eth1 (VPC) | ✓ Migrated |
| k8s-worker01 | 10.118.0.3 | eth1 (VPC) | ✓ Migrated |
| k8s-worker02 | 10.118.0.7 | eth1 (VPC) | ✓ Migrated |

## Applying the Manifest

```bash
kubectl apply -f kube-flannel.yaml
```

## Migration History

VPC migration completed 2026-01-13:

1. Updated DaemonSet to use `--iface=eth1` (forces VPC interface)
2. Updated node annotations to VPC IPs
3. Restarted flannel pods to pick up changes

To verify VXLAN is using VPC IPs:
```bash
kubectl exec -n kube-flannel <pod> -- ip -d link show flannel.1
# Should show: vxlan id 1 local 10.118.0.x
```

## Firewall Requirements

Flannel VXLAN requires UDP port 8472 between all nodes.

Current firewall:
- Allow UDP 8472 from VPC range (10.118.0.0/20)
