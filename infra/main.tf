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