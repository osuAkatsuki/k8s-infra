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

variable "cloudflare_ipv6_ranges" {
  description = "Cloudflare IPv6 ranges"
  type        = list(string)
  default = [
    "2400:cb00::/32",
    "2405:8100::/32",
    "2405:b500::/32",
    "2606:4700::/32",
    "2803:f800::/32",
    "2a06:98c0::/29",
    "2c0f:f248::/32"
  ]
}

# =============================================================================
# EXISTING FIREWALL - Imported from DigitalOcean
# This firewall was created manually and is now managed by Terraform.
# Import command: terraform import digitalocean_firewall.mysql-master01-firewall <firewall-id>
# =============================================================================

resource "digitalocean_firewall" "mysql-master01-firewall" {
  name = "mysql-master01.akatsuki.gg-access"

  droplet_ids = [digitalocean_droplet.mysql-master01-droplet.id]

  # SSH - open (TODO: restrict to Tailscale/VPC in future)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTP - open (Cloudflare proxies, but also direct access allowed)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS - Cloudflare only
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = concat(var.cloudflare_ipv4_ranges, var.cloudflare_ipv6_ranges)
  }

  # MySQL - k8s-production tagged droplets only
  inbound_rule {
    protocol    = "tcp"
    port_range  = "3306"
    source_tags = [digitalocean_tag.k8s-production.name]
  }

  # PostgreSQL - k8s-production tagged droplets only
  inbound_rule {
    protocol    = "tcp"
    port_range  = "5432"
    source_tags = [digitalocean_tag.k8s-production.name]
  }

  # RabbitMQ - k8s-production tagged droplets only
  inbound_rule {
    protocol    = "tcp"
    port_range  = "5672"
    source_tags = [digitalocean_tag.k8s-production.name]
  }

  # Redis - k8s-production tagged droplets only
  inbound_rule {
    protocol    = "tcp"
    port_range  = "6379"
    source_tags = [digitalocean_tag.k8s-production.name]
  }

  # Allow all outbound traffic
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

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
}
