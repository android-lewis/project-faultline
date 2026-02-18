variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "eu-west-2"
}

variable "project_name" {
  type        = string
  description = "Project name for resource naming"
  default     = "project-faultline"
}

variable "environment" {
  type        = string
  description = "Environment (e.g., demo, dev, prod)"
  default     = "demo"
}

variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table name for support tickets"
  default     = "support-tickets"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in the format owner/repo for OIDC trust"
  default     = "android-lewis/project-faultline"
}