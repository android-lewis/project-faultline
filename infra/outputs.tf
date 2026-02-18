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

output "customer_portal_cloudfront_domain" {
  value       = module.cloudfront.customer_portal_domain_name
  description = "Customer portal CloudFront domain name"
}

output "customer_portal_distribution_id" {
  value       = module.cloudfront.customer_portal_distribution_id
  description = "Customer portal CloudFront distribution ID"
}

output "internal_portal_bucket_name" {
  value       = module.s3.internal_portal_bucket_name
  description = "Internal portal S3 bucket name"
}

output "internal_portal_website_endpoint" {
  value       = module.s3.internal_portal_website_endpoint
  description = "Internal portal website endpoint"
}

output "internal_portal_cloudfront_domain" {
  value       = module.cloudfront.internal_portal_domain_name
  description = "Internal portal CloudFront domain name"
}

output "internal_portal_distribution_id" {
  value       = module.cloudfront.internal_portal_distribution_id
  description = "Internal portal CloudFront distribution ID"
}

output "github_actions_role_arn" {
  value       = module.iam.github_actions_role_arn
  description = "ARN of the GitHub Actions IAM role for SAM deploy"
}

output "cognito_user_pool_id" {
  value       = module.cognito.user_pool_id
  description = "Cognito User Pool ID (for SAM and portals)"
}

output "cognito_user_pool_arn" {
  value       = module.cognito.user_pool_arn
  description = "Cognito User Pool ARN (for SAM)"
}

output "cognito_user_pool_endpoint" {
  value       = module.cognito.user_pool_endpoint
  description = "Cognito User Pool endpoint"
}

output "cognito_customer_portal_client_id" {
  value       = module.cognito.customer_portal_client_id
  description = "Cognito App Client ID for customer portal"
}

output "cognito_internal_portal_client_id" {
  value       = module.cognito.internal_portal_client_id
  description = "Cognito App Client ID for internal portal"
}

output "cognito_user_pool_domain" {
  value       = module.cognito.user_pool_domain
  description = "Cognito User Pool domain"
}
