variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "customer_portal_callback_urls" {
  description = "List of callback URLs for customer portal OAuth"
  type        = list(string)
}

variable "customer_portal_logout_urls" {
  description = "List of logout URLs for customer portal OAuth"
  type        = list(string)
}

variable "internal_portal_callback_urls" {
  description = "List of callback URLs for internal portal OAuth"
  type        = list(string)
}

variable "internal_portal_logout_urls" {
  description = "List of logout URLs for internal portal OAuth"
  type        = list(string)
}
