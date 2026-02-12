variable "project_name" {
  type        = string
  description = "Project name for resource naming"
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention in days"
  default     = 14
}
