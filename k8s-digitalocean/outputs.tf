output "kube_config" {
  value     = module.k8s_cluster.kube_config
  sensitive = true
}

output "load_balancer_name_from_helm" {
  value = module.k8s_apps.provisioned_load_balancer_name
}
