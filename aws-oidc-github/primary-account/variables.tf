variable "github_organization" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "secondary_account_id" {
  type        = string
  nullable    = true
  description = "ID of the secondary AWS account"
}

variable "secondary_account_role" {
  type        = string
  nullable    = true
  description = "Role defined in the secondary account"
  default     = "DevOpsOIDC"
}
