# These resources will be used by all environments

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

# Create container registry
resource "digitalocean_container_registry" "akatsuki" {
  name                   = "akatsuki"
  subscription_tier_slug = "starter"
  region                 = "nyc3"
}
