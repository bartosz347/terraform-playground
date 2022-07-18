terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
}

resource "aws_vpc" "main" {
  cidr_block = var.main_vpc_cidr_block

  tags = {
    Info = "terraform-test-can-be-removed"
    Environment = var.environment_name
  }
}
