output "customer_portal_bucket_name" {
  value       = aws_s3_bucket.customer_portal_bucket.bucket
  description = "Customer portal S3 bucket name"
}

output "customer_portal_bucket_id" {
  value       = aws_s3_bucket.customer_portal_bucket.id
  description = "Customer portal S3 bucket ID"
}

output "customer_portal_bucket_arn" {
  value       = aws_s3_bucket.customer_portal_bucket.arn
  description = "Customer portal S3 bucket ARN"
}

output "customer_portal_bucket_regional_domain_name" {
  value       = aws_s3_bucket.customer_portal_bucket.bucket_regional_domain_name
  description = "Customer portal S3 bucket regional domain name"
}

output "customer_portal_website_endpoint" {
  value       = aws_s3_bucket_website_configuration.customer_portal_bucket.website_endpoint
  description = "Customer portal website endpoint"
}

output "internal_portal_bucket_name" {
  value       = aws_s3_bucket.internal_portal_bucket.bucket
  description = "Internal portal S3 bucket name"
}

output "internal_portal_bucket_id" {
  value       = aws_s3_bucket.internal_portal_bucket.id
  description = "Internal portal S3 bucket ID"
}

output "internal_portal_bucket_arn" {
  value       = aws_s3_bucket.internal_portal_bucket.arn
  description = "Internal portal S3 bucket ARN"
}

output "internal_portal_bucket_regional_domain_name" {
  value       = aws_s3_bucket.internal_portal_bucket.bucket_regional_domain_name
  description = "Internal portal S3 bucket regional domain name"
}

output "internal_portal_website_endpoint" {
  value       = aws_s3_bucket_website_configuration.internal_portal_bucket.website_endpoint
  description = "Internal portal website endpoint"
}

output "tickets_bucket_id" {
  value       = aws_s3_bucket.tickets_bucket.id
  description = "Tickets S3 bucket ID"
}

output "tickets_bucket_name" {
  value       = aws_s3_bucket.tickets_bucket.bucket
  description = "Tickets S3 bucket name"
}

output "tickets_bucket_arn" {
  value       = aws_s3_bucket.tickets_bucket.arn
  description = "Tickets S3 bucket ARN"
}
