variable "do_token" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "node_count" {
  type        = number
  default     = 1
  description = "Count of Kubernetes worker nodes"
}
