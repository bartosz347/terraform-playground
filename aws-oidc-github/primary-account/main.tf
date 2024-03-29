# Main account configuration
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

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  # Audiences
  client_id_list = ["sts.amazonaws.com"]

  # There is no need to configure trusted thumbprints,
  # because AWS secures communication by trusting
  # GitHub Actions’s trusted root certificate authorities (CAs)
  # https://github.blog/changelog/2023-07-13-github-actions-oidc-integration-with-aws-no-longer-requires-pinning-of-intermediate-tls-certificates/
  thumbprint_list = []
}

resource "aws_iam_role" "oidc_github_actions_primary" {
  name        = "GitHubActionsOIDC"
  description = "Role to test OIDC"

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]

  dynamic "inline_policy" {
    for_each = var.secondary_account_id != null && var.secondary_account_role != null ? [1] : []

    content {
      name = "AllowToAssumeSecondAccountRole"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action   = "sts:AssumeRole"
            Effect   = "Allow"
            Resource = "arn:aws:iam::${var.secondary_account_id}:role/${var.secondary_account_role}"
          }
        ]
      })
    }
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Condition = {
          "StringLike" = {
            # TODO: Branch restrictions can be configured, it's worth to configure branch protection rules
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_organization}/${var.github_repo}:*"
          },
          "StringEquals" = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      },
    ]
  })
}

resource "random_id" "bucket_prefix" {
  byte_length = 4
}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "${random_id.bucket_prefix.hex}-oidc-test-bucket-primary"
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
  key    = "this-is-primary-account"
}
