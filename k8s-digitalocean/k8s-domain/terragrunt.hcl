include "root" {
  path = find_in_parent_folders()
}

dependency "k8s-app" {
  config_path = "../k8s-app"
  skip_outputs = true
}
