terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}
variable "do_ssh_key" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create a new k8s cluster
resource "digitalocean_kubernetes_cluster" "akatsuki-staging-k8s" {
  name    = "akatsuki-staging"
  region  = "tor1"
  version = "1.25.4-do.0"

  node_pool {
    name       = "autoscale-worker-pool"
    size       = "s-2vcpu-4gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 5
  }
}

# Create a postgres database
resource "digitalocean_database_cluster" "postgres-staging" {
  name       = "postgres-cluster-staging"
  engine     = "pg"
  version    = "15"
  size       = "db-s-1vcpu-1gb"
  region     = "tor1"
  node_count = 1
}

# Create a redis database
resource "digitalocean_database_cluster" "redis-staging" {
  name       = "redis-cluster-staging"
  engine     = "redis"
  version    = "5"
  size       = "db-s-1vcpu-1gb"
  region     = "tor1"
  node_count = 1
}

# Create a droplet running openvpn server
resource "digitalocean_droplet" "openvpn-server" {
  image     = "ubuntu-20-04-x64"
  name      = "openvpn-server"
  region    = "tor1"
  size      = "s-1vcpu-1gb"
  ssh_keys  = ["${var.do_ssh_key}"]
  user_data = template_file.openvpn_userdata.rendered
}

resource "template_file" "openvpn_userdata" {
  template = "openvpn.yml"
}

output "droplet_ip" {
  value = digitalocean_droplet.openvpn-server.ipv4_address
}
