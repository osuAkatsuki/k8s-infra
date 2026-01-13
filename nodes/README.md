# Node Configuration

This directory contains node-specific configuration files for the Kubernetes cluster.

## Kubelet Configuration

Each node has a kubelet configuration file at `/var/lib/kubelet/kubeadm-flags.env`.

### Files

- `kubelet-config/master.env` - k8s-master01 configuration
- `kubelet-config/worker01.env` - k8s-worker01 configuration
- `kubelet-config/worker02.env` - k8s-worker02 configuration

### Key Differences

| Node | --node-ip | InternalIP | Notes |
|------|-----------|------------|-------|
| k8s-master01 | (none) | 159.203.62.14 (public) | No override, minimal pod traffic |
| k8s-worker01 | 10.118.0.3 | 10.118.0.3 (VPC) | Uses VPC IP for kubelet API |
| k8s-worker02 | 10.118.0.7 | 10.118.0.7 (VPC) | Uses VPC IP for kubelet API |

**Note**: The `--node-ip` flag controls what kubelet reports as InternalIP. Workers use VPC IPs
to route kubelet API traffic over the private network. The master doesn't override this since
it handles minimal pod traffic, but it still has a VPC IP (10.118.0.2) used by flannel.

### Applying Changes

To update kubelet configuration on a node:

```bash
# SSH to the node
ssh root@<node>

# Edit the kubelet flags
vim /var/lib/kubelet/kubeadm-flags.env

# Restart kubelet
systemctl restart kubelet

# Verify the node is ready
kubectl get nodes
```

## VPC IP Reference

DigitalOcean VPC: 10.118.0.0/20 (NYC1)

| Host | Public IP | VPC IP (eth1) |
|------|-----------|---------------|
| k8s-master01 | 159.203.62.14 | 10.118.0.2 |
| k8s-worker01 | 138.197.146.243 | 10.118.0.3 |
| k8s-worker02 | 68.183.194.110 | 10.118.0.7 |
| mysql-master01 | - | 10.118.0.4 |
