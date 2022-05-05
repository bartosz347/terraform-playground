output "demo_page" {
  value = module.cdn.cloudfront_distribution_domain_name
}

output "demo_script" {
  value = local_file.headers_demo_script.filename
}

output "cloudfront_distribution_status" {
  value = module.cdn.cloudfront_distribution_status
}
