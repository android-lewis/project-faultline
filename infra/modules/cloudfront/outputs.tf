output "customer_portal_domain_name" {
  value       = aws_cloudfront_distribution.customer_portal.domain_name
  description = "CloudFront domain name for customer portal"
}

output "customer_portal_distribution_id" {
  value       = aws_cloudfront_distribution.customer_portal.id
  description = "CloudFront distribution ID for customer portal"
}

output "internal_portal_domain_name" {
  value       = aws_cloudfront_distribution.internal_portal.domain_name
  description = "CloudFront domain name for internal portal"
}

output "internal_portal_distribution_id" {
  value       = aws_cloudfront_distribution.internal_portal.id
  description = "CloudFront distribution ID for internal portal"
}
