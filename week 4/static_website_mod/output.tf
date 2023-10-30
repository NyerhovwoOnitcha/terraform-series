# Output variable definitions

output "website_bucket_arn" {
  description = "ARN of the bucket"
  value       = module.s3_static_website.arn
}

output "website_bucket_name" {
  description = "Name (id) of the bucket"
  value       = module.s3_static_website.name
}

output "website_endpoint" {
  description = "Domain name of the bucket"
  value       = module.s3_static_website.website_endpoint
}

output "object_url" {
  value = module.s3_static_website.object_url
}