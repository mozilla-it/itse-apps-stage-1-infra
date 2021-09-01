resource "aws_cloudfront_distribution" "discourse" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = ["cdn.${local.workspace.discourse_cdn_zone}"]
  comment             = "Discourse ${local.workspace.environment} CDN"
  price_class         = local.workspace.cf_price_class
  depends_on = [
    aws_acm_certificate.cdn,
    aws_acm_certificate_validation.cdn,
  ]

  origin {
    domain_name = local.workspace.discourse_cdn_zone
    origin_id   = "discourse-pull-origin-old"
    origin_path = ""

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only" # Only talk to the origin over HTTPS
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  origin {
    domain_name = "discourse.${local.workspace.environment}.mozit.cloud"
    origin_id   = "discourse-pull-origin"
    origin_path = ""

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only" # Only talk to the origin over HTTPS
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cdn_logs.bucket_domain_name
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "discourse-pull-origin"
    compress         = local.workspace.cf_cache_compress

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 360
    max_ttl                = 3600
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 502
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 503
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 504
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cdn.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}

resource "aws_acm_certificate" "cdn" {
  domain_name       = "cdn.${local.workspace.discourse_cdn_zone}"
  validation_method = "DNS"
  provider          = aws.us-east-1

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cdn_cert_validation" {
  name    = tolist(aws_acm_certificate.cdn.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.cdn.domain_validation_options)[0].resource_record_type
  zone_id = aws_route53_zone.cdn.id
  records = [tolist(aws_acm_certificate.cdn.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cdn" {
  certificate_arn         = aws_acm_certificate.cdn.arn
  validation_record_fqdns = [aws_route53_record.cdn_cert_validation.fqdn]
  provider                = aws.us-east-1
}

resource "random_id" "cdn_logs" {
  byte_length = 6
}

data "aws_canonical_user_id" "current_user" {}

resource "aws_s3_bucket" "cdn_logs" {
  bucket = "discourse-${local.workspace.environment}-cdn-logs-${random_id.cdn_logs.dec}"

  grant {
    id          = data.aws_canonical_user_id.current_user.id
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
  }

  grant {
    id          = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
  }
}

resource "aws_route53_record" "cdn_alias" {
  name    = "cdn.${local.workspace.discourse_cdn_zone}"
  type    = "CNAME"
  zone_id = aws_route53_zone.cdn.id
  records = [aws_cloudfront_distribution.discourse.domain_name]
  ttl     = 60
}

resource "aws_route53_zone" "cdn" {
  name          = "${local.workspace.discourse_cdn_zone}."
  force_destroy = "false"
}
