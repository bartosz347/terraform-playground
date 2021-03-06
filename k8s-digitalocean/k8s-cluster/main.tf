terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.19.0"
    }
  }
}

resource "digitalocean_vpc" "k8s_vpc" {
  name     = "${var.cluster_name}-vpc"
  region   = "fra1"
  ip_range = "10.0.0.0/24"

  timeouts {
    delete = "5m"
  }
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
    node_count = var.node_count
  }
}

resource "local_file" "kubeconfig" {
  content  = digitalocean_kubernetes_cluster.kubernetes_cluster.kube_config.0.raw_config
  filename = "${path.root}/kubeconfig"
}
