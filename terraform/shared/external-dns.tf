locals {
  external_dns_name_prefix = "${module.itse-apps-stage-1.cluster_id}-external-dns"
  external_dns_namespace   = "kube-system"

  external_dns_chart_settings = {
    "provider"                                                  = "aws"
    "policy"                                                    = "sync"
    "replicas"                                                  = "1"
    "metrics.enabled"                                           = "true"
    "txtOwnerId"                                                = "${module.itse-apps-stage-1.cluster_id}-${random_string.string.result}"
    "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.external_dns_role.this_iam_role_arn
    # NOTE: The default option for this is actually ['service', 'ingress'] where external-dns
    # crates DNS Records based on the hosts specified in the ingress object. This is less than ideal
    # so we just configure it to check the service annotation instead
    "sources[0]" = "service"
  }

  external_dns_tags = {
    Environment = "stage"
    Terraform   = "true"
  }
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
    resources = [
      "*"
    ]
  }
}

resource "random_string" "string" {
  length  = 8
  special = false
  keepers = {
    cluster_id = module.itse-apps-stage-1.cluster_id
  }
}

resource "aws_iam_policy" "external_dns" {
  name_prefix = "${local.external_dns_name_prefix}-policy-"
  path        = "/"
  description = "IAM Policy for external-dns on ${module.itse-apps-stage-1.cluster_id}"
  policy      = data.aws_iam_policy_document.external_dns.json
}

module "external_dns_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.20.0"
  create_role                   = true
  role_name                     = "${local.external_dns_name_prefix}-role"
  provider_url                  = replace(module.itse-apps-stage-1.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.external_dns.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.external_dns_namespace}:external-dns"]
  tags                          = merge({ Name = "${local.external_dns_name_prefix}-role" }, local.external_dns_tags)
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  namespace  = local.external_dns_namespace

  dynamic "set" {
    iterator = item
    for_each = local.external_dns_chart_settings

    content {
      name  = item.key
      value = item.value
    }
  }

  depends_on = [
    module.itse-apps-stage-1,
    module.external_dns_role
  ]
}
