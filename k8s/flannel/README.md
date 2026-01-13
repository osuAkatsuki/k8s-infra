# Flannel CNI

Flannel provides the pod network overlay using VXLAN.

## Current State

- **Version**: v0.23.0
- **Backend**: VXLAN (UDP port 8472)
- **Pod CIDR**: 10.244.0.0/16

### Node VXLAN IPs

Flannel uses the `flannel.alpha.coreos.com/public-ip` annotation on nodes to determine
which IP to use for VXLAN tunnels.

| Node | Current VXLAN IP | Target VPC IP | Status |
|------|------------------|---------------|--------|
| k8s-master01 | 159.203.62.14 | (keep public) | N/A |
| k8s-worker01 | 138.197.146.243 | 10.118.0.3 | Pending |
| k8s-worker02 | 68.183.194.110 | 10.118.0.7 | Pending |

## Applying the Manifest

```bash
kubectl apply -f kube-flannel.yaml
```

## Migrating to VPC IPs

To migrate flannel VXLAN traffic to use VPC IPs:

1. **Update node annotations** (one node at a time):
   ```bash
   kubectl annotate node k8s-worker01 \
     flannel.alpha.coreos.com/public-ip=10.118.0.3 --overwrite
   ```

2. **Restart flannel pod on that node**:
   ```bash
   kubectl delete pod -n kube-flannel -l app=flannel \
     --field-selector spec.nodeName=k8s-worker01
   ```

3. **Verify VXLAN is using new IP**:
   ```bash
   kubectl exec -n kube-flannel <pod> -- ip -d link show flannel.1
   # Should show: vxlan id 1 local 10.118.0.3
   ```

4. **Test pod connectivity** before proceeding to next node.

5. **Update firewall rules** after all workers are migrated.

## Firewall Requirements

Flannel VXLAN requires UDP port 8472 between all nodes.

Current firewall (source_tags based):
- Allows traffic between all nodes tagged `k8s-production`

Target firewall (VPC based):
- Allow UDP 8472 from VPC range (10.118.0.0/20)
- Allow UDP 8472 from master public IP (159.203.62.14/32)
