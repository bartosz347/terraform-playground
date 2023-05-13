output "role_arn" {
  value = aws_iam_role.oidc_github_actions_secondary.arn
}

output "test_bucket_id" {
  value = aws_s3_bucket.test_bucket.id
}
