## Variables

variable "aws_region" {
  default     = "us-east-1"
}

variable "domain" {
  default = "netxbyteslab.click"
}

provider "aws" {
  region = "${var.aws_region}"
}


## S3 Bucket

# Note: The bucket name needs to carry the same name as the domain!
# http://stackoverflow.com/a/5048129/2966951

resource "aws_s3_bucket" "site" {
  bucket = "${var.domain}"

  website {
      index_document = "index.html"
  }

  tags = {
    Environment = "labs"
  }
}

resource "aws_s3_account_public_access_block" "site" {
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "site_content" {
  depends_on = [ 
    aws_s3_bucket.site
   ]

   bucket = aws_s3_bucket.site.bucket
   key = "index.html"
   source = "./index.html"
   server_side_encryption = "AES256"
   content_type = "text/html"
}

resource "aws_s3_bucket_policy" "site" {
    
  depends_on = [ 
    data.aws_iam_policy_document.site
   ]

   bucket = aws_s3_bucket.site.id
   policy = data.aws_iam_policy_document.site.json
}



#Route53 

# Note: Creating this route53 zone is not enough. The domain's name servers need to point to the NS
# servers of the route53 zone. Otherwise the DNS lookup will fail.
# To verify that the dns lookup succeeds: `dig site @nameserver`

resource "aws_route53_zone" "main" {
  name = "${var.domain}"
}

resource "aws_route53_record" "root_domain" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "${var.domain}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.cdn.domain_name}"
    zone_id = "${aws_cloudfront_distribution.main.hosted_zone_id}"
    evaluate_target_health = false
  }
}


##CloudFront Distibution


resource "aws_cloudfront_origin_access_control" "site_access" {
  name = "security_pillar100_cf_s3_oac" #what is this?
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

resource "aws_cloudfront_distribution" "site_cdn" {

    depends_on = [ 
    aws_s3_bucket.site,
    aws_cloudfront_origin_access_control.site_access
   ]

  # If using route53 aliases for DNS we need to declare it here too, otherwise we'll get 403s.
  aliases = ["${var.domain}"]

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.site.id}"
    viewer_protocol_policy = "https-only"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
  origin {
    origin_id   = "${aws_s3_bucket.var.domain.id}"
    domain_name = "${var.domain}.s3.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.site_access.id
  }

  # The cheapest priceclass
  price_class = "PriceClass_100"

  # This is required to be specified even if it's not used.
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}


## IAM Policy

data "aws_iam_policy_document" "site" {
  depends_on = [ 
    aws_cloudfront_distribution.site,
    aws_s3_bucket.site
   ]

statement {
  sid = "s3_cloudfront_static_website"
  effect = "Allow"
  actions = [ 
    "s3:GetObject"
   ]

principals {
  identifiers = ["cloudfront.amazonaws.com"]
  type = "Service"
}

resources = [
    "arn:aws:s3:::${aws_s3_bucket.site.bucket}/*"
]

condition {
  test = "StringEquals"
  variable = "AWS:SourceArn"

  values = [ aws_cloudfront_distribution.site.arn ]
}
}
}

##Output

output "s3_website_endpoint" {
  value = "${aws_s3_bucket.site.website_endpoint}"
}

output "route53_domain" {
  value = "${aws_route53_record.root_domain.fqdn}"
}

