terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "project-faultline-tfstate"
    key            = "infra/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "opentofu-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3" {
  source       = "./modules/s3"
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
}

module "cloudfront" {
  source       = "./modules/cloudfront"
  project_name = var.project_name
  environment  = var.environment

  customer_portal_bucket_id                   = module.s3.customer_portal_bucket_id
  customer_portal_bucket_arn                  = module.s3.customer_portal_bucket_arn
  customer_portal_bucket_regional_domain_name = module.s3.customer_portal_bucket_regional_domain_name

  internal_portal_bucket_id                   = module.s3.internal_portal_bucket_id
  internal_portal_bucket_arn                  = module.s3.internal_portal_bucket_arn
  internal_portal_bucket_regional_domain_name = module.s3.internal_portal_bucket_regional_domain_name
}

# CORS for the tickets bucket — references both S3 and CloudFront outputs
resource "aws_s3_bucket_cors_configuration" "tickets_bucket_cors" {
  bucket = module.s3.tickets_bucket_id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "GET"]
    allowed_origins = [
      "https://${module.cloudfront.customer_portal_domain_name}",
      "https://${module.cloudfront.internal_portal_domain_name}",
      "http://localhost:5173"
    ]
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
}

module "dynamodb" {
  source       = "./modules/dynamodb"
  project_name = var.project_name
  table_name   = var.dynamodb_table_name
  environment  = var.environment
}

module "iam" {
  source             = "./modules/iam"
  project_name       = var.project_name
  tickets_bucket_arn = module.s3.tickets_bucket_arn
  github_repository  = var.github_repository
}

module "cloudwatch" {
  source       = "./modules/cloudwatch"
  project_name = var.project_name
}

module "cognito" {
  source       = "./modules/cognito"
  project_name = var.project_name
  environment  = var.environment
  customer_portal_callback_urls = [
    "https://${module.cloudfront.customer_portal_domain_name}/callback",
    "http://localhost:5173/callback"
  ]
  customer_portal_logout_urls = [
    "https://${module.cloudfront.customer_portal_domain_name}",
    "http://localhost:5173"
  ]
  internal_portal_callback_urls = [
    "https://${module.cloudfront.internal_portal_domain_name}/callback",
    "http://localhost:5173/callback"
  ]
  internal_portal_logout_urls = [
    "https://${module.cloudfront.internal_portal_domain_name}",
    "http://localhost:5173"
  ]
}