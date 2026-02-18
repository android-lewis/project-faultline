data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_origin_access_control" "portal" {
  name                              = "${var.project_name}-portal-oac"
  description                       = "OAC for portal S3 buckets"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# -----------------------------------------------------------------------------
# Customer Portal Distribution
# -----------------------------------------------------------------------------

resource "aws_cloudfront_distribution" "customer_portal" {
  enabled             = true
  default_root_object = "index.html"
  comment             = "${var.project_name} customer portal"

  origin {
    domain_name              = var.customer_portal_bucket_regional_domain_name
    origin_id                = "S3-customer-portal"
    origin_access_control_id = aws_cloudfront_origin_access_control.portal.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-customer-portal"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  # SPA routing: return index.html for missing paths
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "${var.project_name}-customer-portal-cdn"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "customer_portal" {
  bucket = var.customer_portal_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${var.customer_portal_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.customer_portal.arn
          }
        }
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Internal Portal Distribution
# -----------------------------------------------------------------------------

resource "aws_cloudfront_distribution" "internal_portal" {
  enabled             = true
  default_root_object = "index.html"
  comment             = "${var.project_name} internal portal"

  origin {
    domain_name              = var.internal_portal_bucket_regional_domain_name
    origin_id                = "S3-internal-portal"
    origin_access_control_id = aws_cloudfront_origin_access_control.portal.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-internal-portal"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "${var.project_name}-internal-portal-cdn"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "internal_portal" {
  bucket = var.internal_portal_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${var.internal_portal_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.internal_portal.arn
          }
        }
      }
    ]
  })
}
