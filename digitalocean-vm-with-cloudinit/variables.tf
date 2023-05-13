variable "ssh_access_ip_range_whitelist" {
  type        = set(string)
  description = "List of IP ranges allowed to connect using SSH"

  validation {
    condition = alltrue([
      for value in var.ssh_access_ip_range_whitelist : can(cidrnetmask(value))
    ])
    error_message = "All elements must be valid IPv4 CIDR block addresses."
  }
}

variable "do_ssh_key_ids" {
  type        = set(string)
  description = "List of SSH key IDs/fingerprints defined in DO panel that will be allowed to login to the VM"
}

variable "api_url" {
  type        = string
  description = "URL of the API for monitoring purposes"
}

variable "email_notification_receivers" {
  type        = list(string)
  description = "List of email addresses to notify"
}
