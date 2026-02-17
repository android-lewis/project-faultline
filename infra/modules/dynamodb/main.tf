resource "aws_dynamodb_table" "support_tickets" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "TicketID"

  attribute {
    name = "TicketID"
    type = "S"
  }

  attribute {
    name = "UserID"
    type = "S"
  }

  global_secondary_index {
    name            = "UserID-index"
    key_schema {
      attribute_name = "UserID"
      key_type       = "HASH"
    }
    projection_type = "ALL"
  }

  tags = {
    Name        = var.table_name
    Environment = var.environment
    Project     = var.project_name
  }
}
