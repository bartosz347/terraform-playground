output "bastion_host_public_ip" {
  value = module.bastion_host.public_ip
}

output "postgres_address" {
  value = module.postgres-db.db_instance_address
}
