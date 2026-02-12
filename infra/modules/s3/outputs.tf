output "customer_portal_bucket_name" {
  value       = aws_s3_bucket.customer_portal_bucket.bucket
  description = "Customer portal S3 bucket name"
}

output "customer_portal_website_endpoint" {
  value       = aws_s3_bucket_website_configuration.customer_portal_bucket.website_endpoint
  description = "Customer portal website endpoint"
}

output "internal_portal_bucket_name" {
  value       = aws_s3_bucket.internal_portal_bucket.bucket
  description = "Internal portal S3 bucket name"
}

output "internal_portal_website_endpoint" {
  value       = aws_s3_bucket_website_configuration.internal_portal_bucket.website_endpoint
  description = "Internal portal website endpoint"
}

output "tickets_bucket_name" {
  value       = aws_s3_bucket.tickets_bucket.bucket
  description = "Tickets S3 bucket name"
}

output "tickets_bucket_arn" {
  value       = aws_s3_bucket.tickets_bucket.arn
  description = "Tickets S3 bucket ARN"
}
