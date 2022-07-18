terraform {
  cloud {
    organization = "bw-test"

    workspaces {
      name = "cli-driven-workflow"
    }
  }

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
  cidr_block = "10.30.0.0/16"

  tags = {
    Info = "terraform-test-can-be-removed"
  }
}
