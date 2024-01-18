resource "aws_lambda_function" "tldr" {
  description   = "Post the weekly TL;DR email into Discourse ${local.workspace.environment}"
  function_name = "discourse-${local.workspace.environment}-tldr"
  handler       = "index.handler"
  memory_size   = "256"
  s3_bucket     = aws_s3_bucket.tldr_code.id
  s3_key        = "discourse-tldr.zip"
  role          = aws_iam_role.lambda_tldr.arn
  runtime       = "nodejs12.x"
  timeout       = "60" # value expressed in seconds

  depends_on = [
    aws_iam_role_policy_attachment.tldr,
    aws_cloudwatch_log_group.lambda_tldr,
  ]

  environment {
    variables = {
      DISCOURSE_TLDR_API_KEY      = aws_ssm_parameter.tldr_api_key.value
      DISCOURSE_TLDR_API_USERNAME = "tldr"
      DISCOURSE_TLDR_BUCKET       = aws_s3_bucket.tldr_email.id
      DISCOURSE_TLDR_CATEGORY     = "253"
      DISCOURSE_TLDR_URL          = "https://${local.workspace.discourse_mozilla}"
    }
  }
}

resource "aws_lambda_permission" "tldr_allow_ses" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tldr.function_name
  principal     = "ses.amazonaws.com"
}

resource "aws_iam_role" "lambda_tldr" {
  name = "discourse-${local.workspace.environment}-lambda-tldr"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_cloudwatch_log_group" "lambda_tldr" {
  name              = "/aws/lambda/discourse-${local.workspace.environment}-tldr"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_subscription_filter" "lambda_tldr_papertrail" {
  name            = "discourse-${local.workspace.environment}-tldr-logs-to-papertrail"
  log_group_name  = aws_cloudwatch_log_group.lambda_tldr.name
  destination_arn = data.terraform_remote_state.vpc.outputs.cloudwatch_to_papertrail_lambda_arn
  filter_pattern  = ""
}

resource "aws_iam_policy" "lambda_tldr" {
  name = "discourse-${local.workspace.environment}-lambda-tldr"
  path = "/discourse/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": "s3:GetObject",
      "Resource": [
				"${aws_s3_bucket.tldr_email.arn}",
				"${aws_s3_bucket.tldr_email.arn}/*"
			],
      "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "tldr" {
  role       = aws_iam_role.lambda_tldr.name
  policy_arn = aws_iam_policy.lambda_tldr.arn
}

resource "aws_s3_bucket" "tldr_email" {
  bucket = "discourse-${local.workspace.environment}-tldr-email"
  acl    = "private"
  lifecycle {
    ignore_changes = [server_side_encryption_configuration]
  }
}

resource "aws_s3_bucket" "tldr_code" {
  bucket = "discourse-${local.workspace.environment}-tldr-code"
  acl    = "private"
  lifecycle {
    ignore_changes = [server_side_encryption_configuration]
  }
}

resource "aws_s3_bucket_policy" "tldr_emails" {
  bucket = aws_s3_bucket.tldr_email.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowSESPuts",
            "Effect": "Allow",
            "Principal": {
                "Service": "ses.amazonaws.com"
						},
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.tldr_email.arn}/*"
				}
    ]
}
POLICY

}

resource "aws_ssm_parameter" "tldr_api_key" {
  name  = "/discourse/${local.workspace.environment}/tldr-api-key"
  type  = "String"
  value = "non-real-key"

  lifecycle {
    ignore_changes = [value]
  }
}
