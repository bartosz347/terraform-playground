module "sg_postgres_db" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.8"

  name        = "postgres-sg"
  description = "PostgreSQL security group"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.sg_bastion_host.security_group_id
      description              = "Allow access from bastion host"
    },
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.sg_private_server.security_group_id
      description              = "Allow access from private server"
    }
  ]
}

module "postgres-db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 4.1.3"

  identifier = "demodb"

  engine               = "postgres"
  engine_version       = "13.4"
  family               = "postgres13"
  major_engine_version = "13.4"
  instance_class       = "db.t4g.micro"

  allocated_storage = 20

  db_name                = "demodb"
  username               = "db_user"
  create_random_password = false
  password               = var.db_password
  port                   = "5432"

  iam_database_authentication_enabled = false

  skip_final_snapshot = true # dev only
  maintenance_window  = "Mon:00:00-Mon:03:00"
  backup_window       = "03:00-06:00"

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  create_db_subnet_group = true
  db_subnet_group_name   = "db_subnet"
  vpc_security_group_ids = [module.sg_postgres_db.security_group_id]
  subnet_ids             = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  deletion_protection = false

  parameters = []

  options = []
}
