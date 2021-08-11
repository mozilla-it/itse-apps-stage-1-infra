resource "aws_s3_bucket" "logs_to_papertrail" {
  acl    = "private"
  bucket = "logs-to-papertrail-lambda-code"
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "logs_to_papertrail" {
  # The sourced code of this function is in https://github.com/Signiant/PaperWatch
  description   = "Sends log from a Cloudwatch subscription to Papertrail"
  function_name = "arn:aws:lambda:${local.workspace.region}:${data.aws_caller_identity.current.account_id}:function:cloudwatch-to-papertrail"
  handler       = "src/lambda.handler"
  memory_size   = "128"
  role          = aws_iam_role.logs_to_papertrail.arn
  runtime       = "nodejs10.x"
  s3_bucket     = aws_s3_bucket.logs_to_papertrail.id
  s3_key        = "lambda.zip"
  timeout       = "300"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_lambda_logs" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.logs_to_papertrail.function_name
  principal     = "logs.us-west-2.amazonaws.com"
  statement_id  = "AllowExecutionFromCloudWatch"
}

resource "aws_iam_role" "logs_to_papertrail" {
  name = "cloudwatch-logs-to-papertrail"

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
