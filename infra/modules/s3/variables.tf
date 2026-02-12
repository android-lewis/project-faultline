variable "project_name" {
  type        = string
  description = "Project name for resource naming"
}

variable "environment" {
  type        = string
  description = "Environment (e.g., demo, dev, prod)"
  default     = "demo"
}

variable "aws_region" {
  type        = string
  description = "AWS region for resources"
}
