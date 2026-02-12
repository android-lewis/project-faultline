resource "aws_dynamodb_table" "support_tickets" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "TicketID"

  attribute {
    name = "TicketID"
    type = "S"
  }

  tags = {
    Name        = var.table_name
    Environment = var.environment
    Project     = var.project_name
  }
}
