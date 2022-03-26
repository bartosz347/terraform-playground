output "provisioned_load_balancer_name" {
  value = jsondecode(helm_release.nginx_ingress.metadata[0].values).controller["service"]["annotations"]["service.beta.kubernetes.io/do-loadbalancer-name"]
}
