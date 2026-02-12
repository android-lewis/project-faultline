resource "aws_s3_bucket" "customer_portal_bucket" {
  bucket = "${var.project_name}-customer-portal"
  tags = {
    Name        = "${var.project_name}-customer-site"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_website_configuration" "customer_portal_bucket" {
  bucket = aws_s3_bucket.customer_portal_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket" "internal_portal_bucket" {
  bucket = "${var.project_name}-internal-portal"
  tags = {
    Name        = "${var.project_name}-internal-site"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_website_configuration" "internal_portal_bucket" {
  bucket = aws_s3_bucket.internal_portal_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket" "tickets_bucket" {
  bucket = "${var.project_name}-tickets"
  tags = {
    Name        = "${var.project_name}-tickets"
    Environment = var.environment
  }
}
