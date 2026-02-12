output "tickets_bucket_name" {
  value       = module.s3.tickets_bucket_name
  description = "Name of the S3 bucket for ticket attachments (for SAM)"
}

output "lambda_s3_policy_arn" {
  value       = module.iam.lambda_s3_policy_arn
  description = "ARN of the IAM policy for Lambda S3 access (for SAM)"
}

output "dynamodb_table_name" {
  value       = module.dynamodb.table_name
  description = "Name of the DynamoDB table for tickets (for SAM)"
}

output "customer_portal_bucket_name" {
  value       = module.s3.customer_portal_bucket_name
  description = "Customer portal S3 bucket name"
}

output "customer_portal_website_endpoint" {
  value       = module.s3.customer_portal_website_endpoint
  description = "Customer portal website endpoint"
}

output "internal_portal_bucket_name" {
  value       = module.s3.internal_portal_bucket_name
  description = "Internal portal S3 bucket name"
}

output "internal_portal_website_endpoint" {
  value       = module.s3.internal_portal_website_endpoint
  description = "Internal portal website endpoint"
}

output "github_actions_role_arn" {
  value       = module.iam.github_actions_role_arn
  description = "ARN of the GitHub Actions IAM role for SAM deploy"
}
