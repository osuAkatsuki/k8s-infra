variable "do_token" {}
variable "pvt_key" {}

data "digitalocean_ssh_key" "cmyui_ssh_key" {
  name = "cmyui desktop"
}

resource "digitalocean_project" "akatsuki-production" {
  name        = "akatsuki-production"
  description = null
  purpose     = "Web Application"
  environment = "Production"
  is_default  = true
}

resource "digitalocean_vpc" "akatsuki-production-vpc" {
  region      = "tor1"
  name        = "akatsuki-production"
  description = null
  ip_range    = "10.118.0.0/20"
}

resource "digitalocean_tag" "k8s-production" {
  name = "k8s-production"
}

resource "digitalocean_droplet" "k8s-master01-droplet" {
  region      = "tor1"
  name        = "k8s-master01.akatsuki.gg"
  image       = "140878882"
  size        = "s-2vcpu-2gb"
  backups     = false
  resize_disk = true
  tags        = [digitalocean_tag.k8s-production.name]
  vpc_uuid    = digitalocean_vpc.akatsuki-production-vpc.id
}

resource "digitalocean_droplet" "k8s-worker01-droplet" {
  region      = "tor1"
  name        = "k8s-worker01.akatsuki.gg"
  image       = "140878882"
  size        = "s-4vcpu-8gb-intel"
  backups     = false
  resize_disk = true
  tags        = [digitalocean_tag.k8s-production.name]
  vpc_uuid    = digitalocean_vpc.akatsuki-production-vpc.id
}

resource "digitalocean_droplet" "k8s-worker02-droplet" {
  region      = "tor1"
  name        = "k8s-worker02.akatsuki.gg"
  image       = "ubuntu-23-10-x64"
  size        = "s-4vcpu-8gb-intel"
  backups     = false
  resize_disk = true
  tags        = [digitalocean_tag.k8s-production.name]
  vpc_uuid    = digitalocean_vpc.akatsuki-production-vpc.id
}

resource "digitalocean_droplet" "mysql-master01-droplet" {
  region      = "tor1"
  name        = "mysql-master01.akatsuki.gg"
  image       = "ubuntu-23-10-x64"
  size        = "s-4vcpu-8gb-intel"
  backups     = false
  resize_disk = true
  tags        = []
  vpc_uuid    = digitalocean_vpc.akatsuki-production-vpc.id
}

# Firewall rules for Kubernetes cluster security
# Restricts access to K8s control plane and internal services

# Tailscale CGNAT range for admin SSH access
# k8s-master01 acts as bastion; other servers accessed via VPC ProxyJump
variable "tailscale_ipv4_range" {
  description = "Tailscale CGNAT IPv4 range"
  type        = string
  default     = "100.64.0.0/10"
}

# Cloudflare IP ranges for allowing HTTP/HTTPS traffic
# https://www.cloudflare.com/ips/
variable "cloudflare_ipv4_ranges" {
  description = "Cloudflare IPv4 ranges"
  type        = list(string)
  default = [
    "173.245.48.0/20",
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "141.101.64.0/18",
    "108.162.192.0/18",
    "190.93.240.0/20",
    "188.114.96.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "162.158.0.0/15",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "172.64.0.0/13",
    "131.0.72.0/22"
  ]
}

# Firewall for Kubernetes master node
resource "digitalocean_firewall" "k8s-master-firewall" {
  name = "k8s-master-firewall"

  droplet_ids = [digitalocean_droplet.k8s-master01-droplet.id]

  # SSH - only from Tailscale (bastion access point)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [var.tailscale_ipv4_range]
  }

  # Kubernetes API - only from VPC (internal cluster communication)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "6443"
    source_addresses = [digitalocean_vpc.akatsuki-production-vpc.ip_range]
  }

  # etcd - only from VPC
  inbound_rule {
    protocol         = "tcp"
    port_range       = "2379-2380"
    source_addresses = [digitalocean_vpc.akatsuki-production-vpc.ip_range]
  }

  # Kubelet API - only from VPC
  inbound_rule {
    protocol         = "tcp"
    port_range       = "10250"
    source_addresses = [digitalocean_vpc.akatsuki-production-vpc.ip_range]
  }

  # kube-scheduler - only from VPC
  inbound_rule {
    protocol         = "tcp"
    port_range       = "10251"
    source_addresses = [digitalocean_vpc.akatsuki-production-vpc.ip_range]
  }

  # kube-controller-manager - only from VPC
  inbound_rule {
    protocol         = "tcp"
    port_range       = "10252"
    source_addresses = [digitalocean_vpc.akatsuki-production-vpc.ip_range]
  }

  # Allow all outbound traffic
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Firewall for Kubernetes worker nodes
resource "digitalocean_firewall" "k8s-workers-firewall" {
  name = "k8s-workers-firewall"

  droplet_ids = [
    digitalocean_droplet.k8s-worker01-droplet.id,
    digitalocean_droplet.k8s-worker02-droplet.id,
  ]

  # SSH - only from VPC (accessed via k8s-master01 ProxyJump)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [digitalocean_vpc.akatsuki-production-vpc.ip_range]
  }

  # Kubelet API - only from VPC
  inbound_rule {
    protocol         = "tcp"
    port_range       = "10250"
    source_addresses = [digitalocean_vpc.akatsuki-production-vpc.ip_range]
  }

  # NodePort Services - from VPC and mysql-master01 (nginx reverse proxy)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "30000-32767"
    source_addresses = [
      digitalocean_vpc.akatsuki-production-vpc.ip_range,
      "${digitalocean_droplet.mysql-master01-droplet.ipv4_address}/32"
    ]
  }

  # Note: node_exporter (9100) is NOT exposed externally
  # Prometheus should scrape via VPC

  # Allow all outbound traffic
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Firewall for MySQL/nginx reverse proxy
resource "digitalocean_firewall" "mysql-master-firewall" {
  name = "mysql-master-firewall"

  droplet_ids = [digitalocean_droplet.mysql-master01-droplet.id]

  # SSH - only from VPC (accessed via k8s-master01 ProxyJump)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [digitalocean_vpc.akatsuki-production-vpc.ip_range]
  }

  # HTTP - only from Cloudflare
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = var.cloudflare_ipv4_ranges
  }

  # HTTPS - only from Cloudflare
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = var.cloudflare_ipv4_ranges
  }

  # MySQL - only from VPC (internal services)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "3306"
    source_addresses = [digitalocean_vpc.akatsuki-production-vpc.ip_range]
  }

  # Allow all outbound traffic
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
