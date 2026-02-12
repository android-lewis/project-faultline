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

resource "aws_s3_bucket_cors_configuration" "tickets_bucket_cors" {
  bucket = aws_s3_bucket.tickets_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "GET"]
    allowed_origins = [
      "http://${aws_s3_bucket.customer_portal_bucket.bucket}.s3-website.${var.aws_region}.amazonaws.com",
      "http://${aws_s3_bucket.internal_portal_bucket.bucket}.s3-website.${var.aws_region}.amazonaws.com"
    ]
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket_public_access_block" "customer_portal_public_access" {
  bucket = aws_s3_bucket.customer_portal_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "customer_portal_public_read" {
  bucket = aws_s3_bucket.customer_portal_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.customer_portal_public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.customer_portal_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "internal_portal_public_access" {
  bucket = aws_s3_bucket.internal_portal_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "internal_portal_public_read" {
  bucket = aws_s3_bucket.internal_portal_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.internal_portal_public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.internal_portal_bucket.arn}/*"
      }
    ]
  })
}
