# TODO: is it possible to remove this file (skip creation of `provider.tf`)?
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.19.0"
    }
  }
}
