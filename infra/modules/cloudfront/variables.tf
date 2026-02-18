variable "project_name" {
  type        = string
  description = "Project name for resource naming"
}

variable "environment" {
  type        = string
  description = "Environment tag"
}

variable "customer_portal_bucket_id" {
  type        = string
  description = "Customer portal S3 bucket ID"
}

variable "customer_portal_bucket_arn" {
  type        = string
  description = "Customer portal S3 bucket ARN"
}

variable "customer_portal_bucket_regional_domain_name" {
  type        = string
  description = "Customer portal S3 bucket regional domain name"
}

variable "internal_portal_bucket_id" {
  type        = string
  description = "Internal portal S3 bucket ID"
}

variable "internal_portal_bucket_arn" {
  type        = string
  description = "Internal portal S3 bucket ARN"
}

variable "internal_portal_bucket_regional_domain_name" {
  type        = string
  description = "Internal portal S3 bucket regional domain name"
}
