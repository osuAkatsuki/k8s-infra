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
| k8s-master01 | (none) | 159.203.62.14 (public) | Uses public IP, minimal pod traffic |
| k8s-worker01 | 10.118.0.3 | 10.118.0.3 (VPC) | Uses VPC IP for kubelet API |
| k8s-worker02 | 10.118.0.7 | 10.118.0.7 (VPC) | Uses VPC IP for kubelet API |

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

### VPC IP Reference

From DigitalOcean VPC (10.118.0.0/20):
- k8s-master01: 159.203.62.14 (public only, not on VPC for control plane)
- k8s-worker01: 10.118.0.3
- k8s-worker02: 10.118.0.7
- mysql-master01: 10.118.0.4
