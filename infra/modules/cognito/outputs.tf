output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_endpoint" {
  description = "Cognito User Pool endpoint"
  value       = aws_cognito_user_pool.main.endpoint
}

output "customer_portal_client_id" {
  description = "Cognito App Client ID for customer portal"
  value       = aws_cognito_user_pool_client.customer_portal.id
}

output "internal_portal_client_id" {
  description = "Cognito App Client ID for internal portal"
  value       = aws_cognito_user_pool_client.internal_portal.id
}

output "user_pool_domain" {
  description = "Cognito User Pool domain"
  value       = aws_cognito_user_pool_domain.main.domain
}
