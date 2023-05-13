# This example shows how assume role can be used with OIDC
# Secondary account configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"

  default_tags {
    tags = {
      Project = "BW-OIDC-tests"
    }
  }
}

resource "aws_iam_role" "oidc_github_actions_secondary" {
  name        = "DevOpsOIDC"
  description = "Role to test OIDC"

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.primary_account_id}:role/${var.primary_account_role}"
        }
      },
    ]
  })
}

resource "random_id" "bucket_prefix" {
  byte_length = 4
}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "${random_id.bucket_prefix.hex}-oidc-test-bucket-secondary"
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.test_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "test_file" {
  bucket = aws_s3_bucket.test_bucket.id
  key    = "this-is-secondary-account"
}
