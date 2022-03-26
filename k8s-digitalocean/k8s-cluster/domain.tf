resource "digitalocean_domain" "default" {
  name = var.domain
}

resource "digitalocean_certificate" "cert" {
  # TODO: certificate id may change after renewal, sot it may be necessary to ignore the id changes in Terraform
  #       https://docs.digitalocean.com/products/kubernetes/how-to/configure-load-balancers/#ssl-certificates
  name    = "ingress-certificate-${var.cluster_name}"
  type    = "lets_encrypt"
  domains = [
    digitalocean_domain.default.name,
    "*.${digitalocean_domain.default.name}"
  ]
}

data digitalocean_loadbalancer "ingress_loadbalancer" {
  name = var.ingress_loadbalancer_name
}

resource "digitalocean_record" "www" {
  domain = digitalocean_domain.default.id
  type   = "A"
  name   = "*"
  value  = data.digitalocean_loadbalancer.ingress_loadbalancer.ip
}
