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
