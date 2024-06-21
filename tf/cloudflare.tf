variable "cloudflare_api_token" {}
variable "cloudflare_zone_id" {}
variable "cloudflare_account_id" {}
variable "cloudflare_domain" {}

resource "cloudflare_record" "terraform_managed_resource_c777c536e462f6e23c88838db09ecc15" {
  name    = "akatsuki.gg"
  proxied = true
  ttl     = 1
  type    = "A"
  value   = "68.183.196.157"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_179f0b68cd0e7f97a07175291846cc1f" {
  name    = "a"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_7097f7485cca66490f13b70f7309453b" {
  name    = "air_conditioning"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_94b09abead16cf373a0e864a6a405253" {
  name    = "assets"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_6ee19f44bf87065363caee9d3c05a7a5" {
  name    = "b"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_fad0bd13cea5e0fb81469c735ecb612a" {
  name    = "beatmaps"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_716ef8ba0d0d3bf5ac99d7b86afa7477" {
  name    = "c"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_60590adccff06bef9cc8cd88cfcb7595" {
  name    = "difficulty"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_49009678a2c31101a4b0484428c5ee9e" {
  name    = "old"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_e5f9fa810f24478ec6212e2e5bd40542" {
  name    = "osu"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_e0d1427279c9900c22b897d7b33efd9c" {
  name    = "payments"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_f8963f0589aab4febc666e249e3b18a3" {
  name    = "performance"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_ac35937a3b1dd16002c34ff979c1c69c" {
  name    = "relax"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_e3e21a2cfcf8d367fb84fffd12881f8d" {
  name    = "rework"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_660b7bf2540aeb1d28590e866876ca44" {
  name    = "reworks"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_607a671bcc399aee897f192ffbf904e2" {
  name    = "s"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_4661649de0c6385b1bc5c4a10c33ba8f" {
  name    = "vault"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_d37fc100eb9a8a0eec2f25281d95a7b1" {
  name    = "www"
  proxied = true
  ttl     = 1
  type    = "CNAME"
  value   = "akatsuki.gg"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_cddb658c1a211af6540fc615cae450ca" {
  name     = "akatsuki.gg"
  priority = 15
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "3h5azgn53tixa3a2yxyqkgyethll22hdjl7jj5jshsfw2wpalkhq.mx-verification.google.com"
  zone_id  = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_bbe86d4aacefd3b9e041971237326ad3" {
  name     = "akatsuki.gg"
  priority = 10
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "alt4.aspmx.l.google.com"
  zone_id  = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_e053bc92f9485f547e1bab88cd49f63e" {
  name     = "akatsuki.gg"
  priority = 10
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "alt3.aspmx.l.google.com"
  zone_id  = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_ede7c6ea5f4e989e2f41010a704d8ccc" {
  name     = "akatsuki.gg"
  priority = 5
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "alt2.aspmx.l.google.com"
  zone_id  = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_18809f26ceae1650b15bd34708cf5209" {
  name     = "akatsuki.gg"
  priority = 5
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "alt1.aspmx.l.google.com"
  zone_id  = var.cloudflare_zone_id
}

resource "cloudflare_record" "terraform_managed_resource_cc99f7278220097b3f5762ec3d8a964c" {
  name     = "akatsuki.gg"
  priority = 1
  proxied  = false
  ttl      = 1
  type     = "MX"
  value    = "aspmx.l.google.com"
  zone_id  = var.cloudflare_zone_id
}
