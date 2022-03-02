terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  profile = "default" # refers to AWS credentials stored in AWS config file
  region  = "eu-central-1"
}

resource "aws_key_pair" "master_ssh_key" {
  key_name   = "master-ssh-key"
  public_key = file("${path.root}/${var.master_ssh_key_path}")
}
