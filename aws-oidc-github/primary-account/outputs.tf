output "oidc_role_arn" {
  value = aws_iam_role.oidc_github_actions_primary.arn
}

output "test_bucket_id" {
  value = aws_s3_bucket.test_bucket.id
}
