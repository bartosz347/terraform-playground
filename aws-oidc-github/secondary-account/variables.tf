variable "primary_account_id" {
  type        = string
  description = "ID of the primary AWS account"
}

variable "primary_account_role" {
  type        = string
  description = "Role defined for OIDC in the primary account"
  default     = "GitHubActionsOIDC"
}
