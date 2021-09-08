# all the relevant infra for the static site
resource "aws_s3_bucket" "logs" {
  bucket = "mozilla-careers-logs-${local.environment}-783633885093"
  acl    = "log-delivery-write"

  force_destroy = true
}

data "aws_route53_zone" "careers_domain" {
  name = local.r53_zone_name
}



resource "aws_s3_bucket" "mozilla-careers" {
  bucket = local.bucket_name
  acl    = "log-delivery-write"

  force_destroy = true # just for stage, makes it easier to recycle buckets

  hosted_zone_id = local.s3_zone
  logging {
    target_bucket = aws_s3_bucket.logs.bucket
    target_prefix = "stage-logs/"
  }

  website {
    index_document = "index.html"
  }

  website_domain   = local.s3_website_domain
  website_endpoint = local.s3_website_endpoint

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "careers policy",
  "Statement": [
    {
      "Sid": "careersAllowListBucket",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${local.bucket_name}"
    },
    {
      "Sid": "careersAllowGetAll",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${local.bucket_name}/*"
    }
  ]
}
EOF
}

resource "aws_acm_certificate" "careers_cert" {
  provider                  = aws.aws-east
  domain_name               = local.domain_name
  subject_alternative_names = local.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = local.s3_website_endpoint
    origin_id   = "mozilla-careers"
    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "No comment"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    prefix          = "cflogs-stage"
  }

  aliases = local.aliases

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "mozilla-careers"
    compress         = true
    lambda_function_association {
      event_type = "viewer-response"
      lambda_arn = aws_lambda_function.lambda-headers.qualified_arn
    }

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 900
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.careers_cert.arn
    ssl_support_method  = "sni-only"

    # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#minimum_protocol_version
    minimum_protocol_version = "TLSv1"
  }
}


# Lambda@edge to set origin response headers
resource "aws_iam_role" "lambda-edge-role" {
  name = "careers-lambda-exec-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
       ]
     },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


data "archive_file" "lambda-zip" {
  type        = "zip"
  source_file = "${path.module}/lambda-headers.js"
  output_path = "${path.module}/lambda-headers.zip"
}

resource "aws_lambda_function" "lambda-headers" {
  provider         = aws.aws-east
  function_name    = "careers-${local.environment}-resp-headers"
  description      = "Provides Correct Response Headers for careers ${local.environment}"
  publish          = "true"
  filename         = "${path.module}/lambda-headers.zip"
  source_code_hash = data.archive_file.lambda-zip.output_base64sha256
  role             = aws_iam_role.lambda-edge-role.arn
  handler          = "lambda-headers.handler"
  runtime          = "nodejs12.x"

  tags = {
    Name        = "careers-${local.environment}-headers"
    ServiceName = "careers ${local.environment}"
  }
}

resource "aws_route53_record" "careers-cloudfront" {
  zone_id = data.aws_route53_zone.careers_domain.id
  name    = local.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

data "aws_caller_identity" "current" {}

locals {
  cluster_workers_role_name = replace(
    data.terraform_remote_state.k8s.outputs.cluster_worker_iam_role_arn,
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/",
    ""
  )
}

resource "aws_iam_role_policy" "careers_uploads" {
  name = "careers-${local.environment}-uploads"
  role = local.cluster_workers_role_name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.mozilla-careers.arn}/*",
        "${aws_s3_bucket.mozilla-careers.arn}"
			]
    }
  ]
}
EOF

}
