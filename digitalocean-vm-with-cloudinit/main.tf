terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.28.1"
    }
  }

  cloud {
    organization = "todo"

    workspaces {
      name = "infra-prod"
    }
  }

  required_version = ">= 1.4.6"
}

provider "digitalocean" {}

locals {
  region        = "fra1"
  instance_size = "s-1vcpu-512mb-10gb"
}

resource "digitalocean_vpc" "main" {
  name     = "application-vpc"
  region   = local.region
  ip_range = "10.10.30.0/24"
}

resource "digitalocean_droplet" "app_server" {
  name     = "app-server-1"
  region   = local.region
  vpc_uuid = digitalocean_vpc.main.id

  image = "ubuntu-22-04-x64"
  size  = local.instance_size

  monitoring    = true
  droplet_agent = true

  ssh_keys  = var.do_ssh_key_ids
  user_data = file("${path.module}/config/server-config.yaml")

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [user_data, ssh_keys]
  }
}

resource "digitalocean_reserved_ip" "api_ip" {
  region = local.region

  lifecycle {
    prevent_destroy = true
  }
}

resource "digitalocean_reserved_ip_assignment" "application_server_ip" {
  ip_address = digitalocean_reserved_ip.api_ip.ip_address
  droplet_id = digitalocean_droplet.app_server.id
}

resource "digitalocean_firewall" "default_webserver" {
  name        = "default-webserver"
  droplet_ids = [digitalocean_droplet.app_server.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_firewall" "allow_ssh" {
  name        = "allow-ssh-access"
  droplet_ids = [digitalocean_droplet.app_server.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.ssh_access_ip_range_whitelist
  }
}
