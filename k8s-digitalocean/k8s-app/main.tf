terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.19.0"
    }
  }
}

data "digitalocean_kubernetes_cluster" "kubernetes_cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host  = data.digitalocean_kubernetes_cluster.kubernetes_cluster.endpoint
  token = data.digitalocean_kubernetes_cluster.kubernetes_cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.kubernetes_cluster.kube_config[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = data.digitalocean_kubernetes_cluster.kubernetes_cluster.endpoint
    token = data.digitalocean_kubernetes_cluster.kubernetes_cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
      data.digitalocean_kubernetes_cluster.kubernetes_cluster.kube_config[0].cluster_ca_certificate
    )
  }
}

data "digitalocean_certificate" "ssl_certificate" {
  name = "wildcard-ssl-${var.domain}"
}

resource "random_id" "random_name_suffix" {
  byte_length = 5
}

resource "helm_release" "nginx_ingress" {
  name = "ingress-nginx"

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = "true"

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-name"
    value = "ingress-loadbalancer-${var.cluster_name}"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-protocol"
    value = "http"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-tls-ports"
    value = "443"
  }

  set {
    name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-certificate-id"
    # TODO: certificate id may change after renewal, but will be replaced automatically
    #       it may be necessary to ignore the id changes in Terraform
    #       https://docs.digitalocean.com/products/kubernetes/how-to/configure-load-balancers/#ssl-certificates
    value = data.digitalocean_certificate.ssl_certificate.uuid
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-redirect-http-to-https"
    value = "true"
  }

  set {
    name  = "controller.service.targetPorts.https"
    value = 80
  }
}

# TODO: remove?
data "digitalocean_loadbalancer" "ingress_loadbalancer" {
  name = jsondecode(helm_release.nginx_ingress.metadata[0].values).controller["service"]["annotations"]["service.beta.kubernetes.io/do-loadbalancer-name"]
}
