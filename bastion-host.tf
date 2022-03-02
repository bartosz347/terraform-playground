module "sg_bastion_host" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.8"

  name        = "bastion-host-sg"
  description = "Bastion host security group"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access"
      cidr_blocks = var.bastion_allowed_ssh_ip_block
    },
  ]

  egress_with_cidr_blocks = [
    {
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

data "aws_ami" "bastion_host_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:IMAGE_TYPE"
    values = ["bastion"]
  }
}

module "bastion_host" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.4"

  name = "bastion-host"

  ami                    = data.aws_ami.bastion_host_ami.id
  instance_type          = "t2.micro"
  monitoring             = false
  vpc_security_group_ids = [module.sg_bastion_host.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  create_spot_instance = true
  spot_price           = 0.6

  associate_public_ip_address = true

  tags = {}
}
