output "kube_config" {
  value     = module.k8s_cluster.kube_config
  sensitive = true
}

output loadbalancer_public_ip {
  value = module.k8s_app.loadbalancer_public_ip
}
