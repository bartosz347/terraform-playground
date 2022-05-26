include "root" {
  path = find_in_parent_folders()
}

dependency "k8s-cluster" {
  config_path = "../k8s-cluster"
  skip_outputs = true
}

dependency "k8s-ssl-cert" {
  config_path = "../k8s-ssl-cert"
  skip_outputs = true
}
