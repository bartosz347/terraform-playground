output "server_ip" {
  value = digitalocean_reserved_ip.api_ip.ip_address
}
