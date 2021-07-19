#
# SES Domain & Verification Setup within Moderator Environment AWS Zone
#
resource "aws_ses_domain_identity" "main" {
  domain = var.moderator_mozilla
}

resource "aws_ses_domain_identity_verification" "main" {
  domain     = aws_ses_domain_identity.main.id
  depends_on = [aws_route53_record.ses_verification]
}

resource "aws_route53_record" "ses_verification" {
  zone_id = module.moderator_mozilla.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.main.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.main.verification_token]
}

resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "aws_route53_record" "dkim" {
  count   = 3
  zone_id = module.moderator_mozilla.zone_id
  name = format(
    "%s._domainkey.%s",
    element(aws_ses_domain_dkim.main.dkim_tokens, count.index),
    aws_ses_domain_identity.main.domain,
  )
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com"]
}


#
# SES MAIL FROM Domain
#
resource "aws_ses_domain_mail_from" "main" {
  domain           = aws_ses_domain_identity.main.domain
  mail_from_domain = "mail.${aws_ses_domain_identity.main.domain}"
}


#
# SES SPF validaton record & MX from Record
#
resource "aws_route53_record" "spf_mail_from" {
  zone_id = module.moderator_mozilla.zone_id
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_route53_record" "spf_domain" {
  zone_id = module.moderator_mozilla.zone_id
  name    = aws_ses_domain_identity.main.domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_route53_record" "mx_send_mail_from" {
  zone_id = module.moderator_mozilla.zone_id
  name    = aws_ses_domain_mail_from.main.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${var.region}.amazonses.com"]
}

#
# Create IAM user to send email (limited to environment's specific SES identity) 
# for both SDK/API & SMTP credentials in case devs prefer SMTP
#
resource "aws_iam_access_key" "ses" {
  user = aws_iam_user.ses.name
}

resource "aws_iam_user" "ses" {
  name = "${var.project}-${var.environment}-ses"
  path = "/${var.project}/${var.environment}/"
}

resource "aws_iam_user_policy" "ses" {
  name = "${var.project}-${var.environment}-ses"
  user = aws_iam_user.ses.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Effect": "Allow",
      "Resource": "${aws_ses_domain_identity.main.arn}"
    },
    {
      "Action": [
        "ses:GetSendQuota"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}
