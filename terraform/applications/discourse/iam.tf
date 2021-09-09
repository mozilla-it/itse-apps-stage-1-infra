data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "discourse_uploads" {
  name = "discourse-${local.workspace.environment}-uploads"
  role = data.terraform_remote_state.k8s.outputs.cluster_worker_iam_role_name

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
