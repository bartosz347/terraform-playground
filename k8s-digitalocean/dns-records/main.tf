terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.19.0"
    }
  }
}

data "digitalocean_loadbalancer" "ingress_loadbalancer" {
  name = "ingress-loadbalancer-${var.cluster_name}"
}

data "digitalocean_domain" "default" {
  name = var.domain
}

resource "digitalocean_record" "www" {
  domain = data.digitalocean_domain.default.id
  type   = "A"
  name   = "*"
  value  = data.digitalocean_loadbalancer.ingress_loadbalancer.ip
}
