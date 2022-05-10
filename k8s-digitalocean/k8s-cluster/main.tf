terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.19.0"
    }
  }
}

locals {
  cluster_name = "${var.cluster_base_name}-${random_id.random_name_suffix.hex}"
}

resource "random_id" "random_name_suffix" {
  byte_length = 5
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
  name    = local.cluster_name
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
