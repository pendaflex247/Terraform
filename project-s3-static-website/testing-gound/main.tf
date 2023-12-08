provider "aws" {
  region = "us-east-1"
}

variable "root_domain_name" {
  default = "netxbyteslab.click"
}

resource "aws_s3_bucket" "my-bucket" {
  bucket = "${var.root_domain_name}"

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


###Cloud front

locals {
  s3_origin_id = "${var.root_domain_name}"
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
    origin_id   = local.s3_origin_id

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
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "My first CDN"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

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
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}




origin_access_control_id
{
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E9VLYJPNY8X75"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::netxbyteslab.click/*"
        }
    ]
}



origin_access_control_id

{
        "Version": "2008-10-17",
        "Id": "PolicyForCloudFrontPrivateContent",
        "Statement": [
            {
                "Sid": "AllowCloudFrontServicePrincipal",
                "Effect": "Allow",
                "Principal": {
                    "Service": "cloudfront.amazonaws.com"
                },
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::netxbyteslab.click/*",
                "Condition": {
                    "StringEquals": {
                      "AWS:SourceArn": "arn:aws:cloudfront::733275572780:distribution/E23R3VGMCLTAX2"
                    }
                }
            }
        ]
      }