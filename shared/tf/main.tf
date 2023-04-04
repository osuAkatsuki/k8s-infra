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

# Create a droplet running openvpn server
resource "digitalocean_droplet" "openvpn-server" {
  image     = "ubuntu-20-04-x64"
  name      = "openvpn-server"
  region    = "tor1"
  size      = "s-1vcpu-1gb"
  user_data = template_file.openvpn_userdata.rendered
}

resource "template_file" "openvpn_userdata" {
  template = "openvpn.yml"
}

output "droplet_ip" {
  value = digitalocean_droplet.openvpn-server.ipv4_address
}

# Create container registry
resource "digitalocean_container_registry" "akatsuki" {
  name                   = "akatsuki"
  subscription_tier_slug = "starter"
  region                 = "nyc3"
}
