terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.19.0"
    }
  }
}

resource "digitalocean_domain" "default" {
  name = var.domain
}

data "digitalocean_loadbalancer" "ingress_loadbalancer" {
  name = var.ingress_loadbalancer_name
}

resource "digitalocean_record" "www" {
  domain = digitalocean_domain.default.id
  type   = "A"
  name   = "*"
  value  = data.digitalocean_loadbalancer.ingress_loadbalancer.ip
}
