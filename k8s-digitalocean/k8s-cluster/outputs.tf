output "cluster_name" {
  value = digitalocean_kubernetes_cluster.kubernetes_cluster.name
}

output "cluster_id" {
  value = digitalocean_kubernetes_cluster.kubernetes_cluster.id
}

output "kube_config" {
  value     = digitalocean_kubernetes_cluster.kubernetes_cluster.kube_config.0.raw_config
  sensitive = true
}

