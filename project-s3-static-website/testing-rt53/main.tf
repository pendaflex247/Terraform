provider "aws" {
  region = "us-east-1"
}

#To add to this 
#Out put the domain name, the cloudfront ditrubution name
#Discription of how this works
#Modularize this code (S3,Cloudfront,Route53)

variable "root_domain_name" {
  default = "netxbyteslab.click"
}

variable "acm_certificate_arn" {
  description = "ARN of your existing ACM certificate"
  # Replace with the actual ARN of your ACM certificate
  default     = "arn:aws:acm:us-east-1:733275572780:certificate/c137dec1-fa2c-4d3a-9133-51a07fed0e21"
}

variable "route53_zone_id" {
  description = "ID of your Route 53 hosted zone"
  # Replace with the actual ID of your Route 53 hosted zone
  default     = "Z024503619NKX6O5GBRKT"
}

resource "aws_s3_bucket" "my-bucket" {
  bucket = var.root_domain_name

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "my-bucket" {
  bucket = aws_s3_bucket.my-bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "allow_access" {
  bucket = aws_s3_bucket.my-bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:GetObject"],
      Resource = ["arn:aws:s3:::${aws_s3_bucket.my-bucket.bucket}/*"],
      Principal = "*",
      Condition = {
        StringLike = {
          "aws:Referer" = [random_password.custom_header.result],
        }
      }
    }]
  })
}

data "aws_iam_policy_document" "allow_access" {
  policy_id = "PolicyForCloudFrontPrivateContent"
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.my-bucket.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringLike"
      variable = "aws:Referer"
      values   = [random_password.custom_header.result]
    }
  }
}

resource "aws_s3_bucket_acl" "my-bucket" {
  bucket = aws_s3_bucket.my-bucket.id
  acl    = "private"
}

resource "random_password" "custom_header" {
  length      = 13
  special     = false
  lower       = true
  upper       = true
  numeric     = true
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.my-bucket.website_endpoint
    origin_id   = var.root_domain_name

    custom_header {
      name  = "Referer"
      value = random_password.custom_header.result
    }
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  aliases = ["${var.root_domain_name}"]


  enabled             = true
  default_root_object = "index.html"
  is_ipv6_enabled = true
  comment         = "My first CDN"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.root_domain_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_zone" "cloudfront_main" {
  name = "${var.root_domain_name}"
}

resource "aws_route53_record" "cloudfront_record" {
  zone_id = aws_route53_zone.var.route53_zone_id
  name    = "${var.root_domain_name}"
  type    = "A"
  ttl     = 300

  alias {
    name                   = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}