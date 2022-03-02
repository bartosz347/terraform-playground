module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "main"
  cidr = "10.0.0.0/16"

  azs                  = ["eu-central-1a", "eu-central-1b"]
  private_subnets      = ["10.0.10.0/24", "10.0.11.0/24"]
  public_subnets       = ["10.0.20.0/24", "10.0.21.0/24"]
  enable_dns_hostnames = true
}

module "nat" {
  source = "int128/nat-instance/aws"

  enabled = true

  name                        = "main"
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids

  key_name = resource.aws_key_pair.master_ssh_key.key_name
}


resource "aws_eip" "nat" {
  network_interface = module.nat.eni_id
  tags = {
    "Name" = "nat-instance-main"
  }
}

resource "aws_security_group_rule" "sg_nat_instance" {
  description              = "Allow SSH access to NAT instance from bastion host"
  security_group_id        = module.nat.sg_id
  type                     = "ingress"
  source_security_group_id = module.sg_bastion_host.security_group_id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
}
