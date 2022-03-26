terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.18.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_vpc" "k8s_vpc" {
  name     = "k8s-vpc"
  region   = "fra1"
  ip_range = "10.0.0.0/24"
}

data "digitalocean_kubernetes_versions" "version" {
  version_prefix = "1.22."
}

resource "digitalocean_kubernetes_cluster" "kubernetes_cluster" {
  name    = var.cluster_name
  region  = "fra1"
  version = data.digitalocean_kubernetes_versions.version.latest_version
  tags    = []

  vpc_uuid = digitalocean_vpc.k8s_vpc.id
  ha       = false

  node_pool {
    name       = "worker-pool"
    size       = "s-1vcpu-2gb"
    labels     = {}
    node_count = 1
  }
}

resource "local_file" "kubeconfig" {
  content  = digitalocean_kubernetes_cluster.kubernetes_cluster.kube_config.0.raw_config
  filename = "${path.root}/kubeconfig"
}
