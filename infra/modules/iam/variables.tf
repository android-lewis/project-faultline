variable "project_name" {
  type        = string
  description = "Project name for resource naming"
}

variable "tickets_bucket_arn" {
  type        = string
  description = "ARN of the tickets S3 bucket"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in the format owner/repo for OIDC trust"
}
