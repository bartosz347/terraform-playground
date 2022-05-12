# TODO: rate limiting / cap on execution count ?
# TODO: is it possible to fetch just a file instead of using this endpoint?

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
}

locals {
  bucket_name = "s3-bucket"
}

### S3 bucket setup ###
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = local.bucket_name
  force_destroy = true
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = module.cdn.cloudfront_origin_access_identity_iam_arns
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_object" "index_html" {
  bucket       = module.s3_bucket.s3_bucket_id
  key          = "index.html"
  source       = "assets/index.html"
  content_type = "text/html"
  etag         = filemd5("assets/index.html")
}

### CloudFront setup ###
resource "aws_cloudfront_function" "demo_function" {
  name    = "demo-function"
  runtime = "cloudfront-js-1.0"
  publish = true
  code    = file("${path.module}/function.js")
}

module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"

  aliases = []

  comment             = "CloudFront with functions demo"
  enabled             = true
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = false
  default_root_object = "index.html"

  create_origin_access_identity = true
  origin_access_identities      = {
    s3-bucket = "CloudFront CDN can access"
  }

  logging_config = {}

  origin = {
    s3_bucket = {
      domain_name      = module.s3_bucket.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "s3-bucket"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_bucket"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/location-info"
      target_origin_id       = "s3_bucket"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true

      headers = ["Origin", "Cloudfront-Viewer-City", "CloudFront-Viewer-Country", "CloudFront-Viewer-Country-Name"]

      function_association = {
        viewer-request = {
          function_arn = aws_cloudfront_function.demo_function.arn
        }
      }
    }
  ]
}

### Demo script ###
resource "local_file" "headers_demo_script" {
  content  = <<EOT
#!/bin/sh
curl -s -I ${module.cdn.cloudfront_distribution_domain_name}/location-info | grep Data
EOT
  filename = "${path.root}/header_demo.sh"
}
