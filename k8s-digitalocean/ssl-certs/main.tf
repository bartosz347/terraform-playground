terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.19.0"
    }
  }
}

resource "digitalocean_certificate" "cert" {
  # TODO: certificate id may change after renewal, sot it may be necessary to ignore the id changes in Terraform
  #       https://docs.digitalocean.com/products/kubernetes/how-to/configure-load-balancers/#ssl-certificates
  name = "wildcard-ssl-${var.domain}"
  type = "lets_encrypt"
  domains = [
    replace(var.domain, "${split(".", var.domain)[0]}.", ""), # such domain is added automatically by Digital Ocean
    var.domain,
    "*.${var.domain}"
  ]
}
