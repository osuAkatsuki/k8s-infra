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

resource "digitalocean_droplet" "infrastructure01-droplet" {
  region      = "tor1"
  name        = "infrastructure01.akatsuki.gg"
  image       = "ubuntu-23-10-x64"
  size        = "s-2vcpu-2gb"
  backups     = false
  resize_disk = true
  tags        = []
  vpc_uuid    = digitalocean_vpc.akatsuki-production-vpc.id
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

resource "digitalocean_droplet" "k8s-worker04-droplet" {
  region      = "tor1"
  name        = "k8s-worker04.akatsuki.gg"
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

resource "digitalocean_droplet" "rabbitmq-worker01-droplet" {
  region      = "tor1"
  name        = "rabbitmq-worker01.akatsuki.gg"
  image       = "ubuntu-23-10-x64"
  size        = "s-1vcpu-2gb"
  backups     = false
  resize_disk = true
  tags        = []
  vpc_uuid    = digitalocean_vpc.akatsuki-production-vpc.id
}
