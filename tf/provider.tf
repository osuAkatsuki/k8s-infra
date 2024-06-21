terraform {
  # backend "s3" {
  #   bucket = "akatsuki-terraform-state"
  #   key    = "terraform.tfstate"
  #   region = "ca-central-1"
  # }
  backend "kubernetes" {
    secret_suffix = "state"
    config_path   = "~/.kube/config"
  }

  required_providers {
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "~> 5.0"
    # }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
  }
}

# provider "aws" {
#   endpoints {
#     s3  = "https://s3.ca-central-1.wasabisys.com"
#     iam = "https://iam.wasabisys.com"
#     sts = "https://sts.wasabisys.com"
#     sso = "https://sso.wasabisys.com"
#   }
#   region     = "ca-central-1"
#   access_key = var.aws_access_key
#   secret_key = var.aws_secret_key
# }

provider "digitalocean" {
  token = var.do_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
