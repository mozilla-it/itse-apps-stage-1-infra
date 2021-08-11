resource "aws_iam_role" "discourse_role" {
  name               = "discourse-${local.workspace.environment}"
  path               = "/discourse/"
  assume_role_policy = data.aws_iam_policy_document.allow_assume_role.json
}

data "aws_iam_policy_document" "allow_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        # old cluster
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eksctl-k8s-apps-prod-us-west-2-no-NodeInstanceRole-1NUIJ0D2ZYIM0",
        # new cluster
        data.terraform_remote_state.k8s.outputs.cluster_worker_iam_role_arn
      ]
    }
  }
}

resource "aws_iam_role_policy" "discourse" {
  name = "discourse-${local.workspace.environment}"
  role = aws_iam_role.discourse_role.id

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
        "${aws_s3_bucket.uploads.arn}/*",
        "${aws_s3_bucket.uploads.arn}"
			]
    }
  ]
}
EOF

}

output "iam_role_arn" {
  value       = aws_iam_role.discourse_role.arn
  description = "Discourse role ARN"
}
