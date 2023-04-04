# These resources will be used exclusively by the production environment

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

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create a new k8s cluster
resource "digitalocean_kubernetes_cluster" "akatsuki-production-k8s" {
  name    = "akatsuki-production"
  region  = "tor1"
  version = "1.26.3-do.0"

  node_pool {
    name       = "autoscale-worker-pool"
    size       = "s-2vcpu-4gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 5
  }
}

# Create a postgres database
resource "digitalocean_database_cluster" "postgres-production" {
  name       = "postgres-cluster-production"
  engine     = "pg"
  version    = "15"
  size       = "db-s-1vcpu-1gb"
  region     = "tor1"
  node_count = 1
}

# Create a redis database
resource "digitalocean_database_cluster" "redis-production" {
  name       = "redis-cluster-production"
  engine     = "redis"
  version    = "5"
  size       = "db-s-1vcpu-1gb"
  region     = "tor1"
  node_count = 1
}
