# Terraform & Packer demo

## Info
This Terraform configuration creates the following components:
- VPC with public and private subnets
- NAT gateway instance
- Bastion host
- Database server (PostgreSQL RDS)
- Private server

## Building the infrastructure

Packer

```shell
cd images
packer init .
packer validate .
packer build .
cd ..
```

Terraform

```shell
terraform init
terraform plan
terraform apply
```

