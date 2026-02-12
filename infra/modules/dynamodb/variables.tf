variable "table_name" {
  type        = string
  description = "DynamoDB table name for support tickets"
  default     = "support-tickets"
}

variable "project_name" {
  type        = string
  description = "Project name for tagging"
}

variable "environment" {
  type        = string
  description = "Environment (e.g., demo, dev, prod)"
  default     = "demo"
}
