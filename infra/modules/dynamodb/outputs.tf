output "table_name" {
  value       = aws_dynamodb_table.support_tickets.name
  description = "DynamoDB table name"
}

output "table_arn" {
  value       = aws_dynamodb_table.support_tickets.arn
  description = "DynamoDB table ARN"
}
