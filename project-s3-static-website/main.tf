provider "aws" {
  region = "us-east-1"
}

variable "www_domain_name" {
  default = "www.netxbyteslab.click"
}

variable "root_domain_name" {
  default = "netxbyteslab.click"
}

# Create S3 bucket with website configuration
resource "aws_s3_bucket" "www" {
  bucket = "${var.www_domain_name}"

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = {
    Name        = "static website bucket"
    Environment = "Dev"
  }
}

## Create SSL certificate using certificate manager
resource "aws_acm_certificate" "certificate" {
  domain_name              = "*.${var.root_domain_name}"
  status
}

# Create CloudFront distribution
resource "aws_cloudfront_distribution" "www_distribution" {
  origin {
    custom_origin_config {
      http_port               = "80"
      https_port              = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols    = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
    domain_name = "${aws_s3_bucket.www.website_endpoint}"
    origin_id    = "${var.www_domain_name}"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.www_domain_name}"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = ["${var.www_domain_name}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.certificate.arn}"
    ssl_support_method  = "sni-only"
  }
}
