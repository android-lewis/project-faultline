# CloudWatch module
# Note: SAM automatically creates log groups for Lambda functions
# This module is a placeholder for custom log retention or alarm configuration

# Example: Custom log retention for additional log groups
# resource "aws_cloudwatch_log_group" "custom_logs" {
#   name              = "/aws/custom/${var.project_name}"
#   retention_in_days = var.log_retention_days
# }
