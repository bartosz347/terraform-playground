locals {
  ami = "ami-05b308c240ae70bb6"
}

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4"

  trusted_role_services = [
    "ec2.amazonaws.com",
  ]

  create_role = true

  role_name         = "ssm-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
  number_of_custom_role_policy_arns = 1
}

module "sg_private_server" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.8"

  name        = "ssh-sg"
  description = "SSH security group"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.sg_bastion_host.security_group_id
      description              = "Allow access from bastion host"
    }
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

resource "aws_iam_instance_profile" "private_server_profile" {
  name = "private_server_ssm_profile"
  role = module.iam_assumable_role.iam_role_name

  tags = {}
}

module "private_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.4"

  name = "private-server"

  ami           = local.ami
  instance_type = "t2.micro"
  key_name      = resource.aws_key_pair.master_ssh_key.key_name

  monitoring             = false
  vpc_security_group_ids = [module.sg_private_server.security_group_id]
  subnet_id              = module.vpc.private_subnets[0]

  iam_instance_profile = aws_iam_instance_profile.private_server_profile.name

  create_spot_instance = true
  spot_price           = 0.6

  associate_public_ip_address = false

  tags = {}
}
