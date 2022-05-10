include "root" {
  path = find_in_parent_folders()
}

dependency "k8s-cluster" {
  config_path = "../k8s-cluster"

  mock_outputs = {
    cluster_name = "temporary-dummy-cluster-name"
  }
  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate"]
}

dependency "k8s-ssl-cert" {
  config_path = "../k8s-ssl-cert"

  mock_outputs = {
    ssl_certificate_id = "temporary-certificate-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate"]
}

inputs = {
  cluster_name              = dependency.k8s-cluster.outputs.cluster_name
  ssl_certificate_id        = dependency.k8s-ssl-cert.outputs.ssl_certificate_id
}
