resource "random_id" "cluster_name_suffix" {
  byte_length = 5
}

locals {
  cluster_name              = "kubernetes-cluster-${random_id.cluster_name_suffix.hex}"
  ingress_loadbalancer_name = "ingress-loadbalancer-${random_id.cluster_name_suffix.hex}"
}

module "k8s_cluster" {
  source   = "./k8s-cluster"
  do_token = var.do_token

  cluster_name              = local.cluster_name
  domain                    = var.domain
  ingress_loadbalancer_name = module.k8s_apps.provisioned_load_balancer_name
}

module "k8s_apps" {
  source   = "./k8s-apps"
  do_token = var.do_token

  cluster_name              = module.k8s_cluster.cluster_name
  ingress_loadbalancer_name = local.ingress_loadbalancer_name
  ssl_certificate_id        = module.k8s_cluster.ssl_certificate_id
  domain                    = var.domain
}
