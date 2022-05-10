include "root" {
  path = find_in_parent_folders()
}

dependency "k8s-app" {
  config_path = "../k8s-app"

  mock_outputs = {
    provisioned_load_balancer_name = "temporary-dummy-load-balancer-name"
  }
  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate"]
}

inputs = {
  ingress_loadbalancer_name = dependency.k8s-app.outputs.provisioned_load_balancer_name
}
