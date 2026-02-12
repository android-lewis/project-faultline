output "lambda_s3_policy_arn" {
  value       = aws_iam_policy.lambda_s3_policy.arn
  description = "ARN of the Lambda S3 access policy"
}

output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "ARN of the GitHub Actions IAM role for SAM deploy"
}
