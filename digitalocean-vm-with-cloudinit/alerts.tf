# Services
resource "digitalocean_uptime_check" "api" {
  name    = "API uptime check"
  target  = var.api_url
  regions = ["eu_west", "us_east"]
}

resource "digitalocean_uptime_alert" "api_uptime_alert" {
  name       = "api-down-alert"
  check_id   = digitalocean_uptime_check.api.id
  type       = "down"
  period     = "2m"
  comparison = "less_than"
  threshold  = 1

  notifications {
    email = var.email_notification_receivers
  }
}

resource "digitalocean_uptime_alert" "api_latency_alert" {
  name       = "api-latency-alert"
  check_id   = digitalocean_uptime_check.api.id
  type       = "latency"
  period     = "2m"
  comparison = "greater_than"
  threshold  = 400

  notifications {
    email = var.email_notification_receivers
  }
}

# Infra
resource "digitalocean_monitor_alert" "cpu_alert" {
  alerts {
    email = var.email_notification_receivers
  }

  window      = "5m"
  type        = "v1/insights/droplet/cpu"
  compare     = "GreaterThan"
  value       = 80
  enabled     = true
  entities    = [digitalocean_droplet.app_server.id]
  description = "High CPU usage alert"
}

resource "digitalocean_monitor_alert" "ram_alert" {
  alerts {
    email = var.email_notification_receivers
  }

  window      = "5m"
  type        = "v1/insights/droplet/memory_utilization_percent"
  compare     = "GreaterThan"
  value       = 80
  enabled     = true
  entities    = [digitalocean_droplet.app_server.id]
  description = "High RAM usage alert"
}

resource "digitalocean_monitor_alert" "disk_alert" {
  alerts {
    email = var.email_notification_receivers
  }

  window      = "5m"
  type        = "v1/insights/droplet/disk_utilization_percent"
  compare     = "GreaterThan"
  value       = 70
  enabled     = true
  entities    = [digitalocean_droplet.app_server.id]
  description = "Low disk space alert"
}
