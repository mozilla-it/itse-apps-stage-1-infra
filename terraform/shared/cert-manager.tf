locals {
  cert_manager_version      = "v1.0.2"
  cert_manager_crd_manifest = "https://github.com/jetstack/cert-manager/releases/download/${local.cert_manager_version}/cert-manager.crds.yaml"
  cert_manager_name_prefix  = "${module.itse-apps-stage-1.cluster_id}-cert-manager"
  cert_manager_namespace    = "cert-manager"
  cert_manager_settings = {
    "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.cert_manager_role.iam_role_arn
    "extraArgs[0]"                                              = "--issuer-ambient-credentials"
    "securityContext.fsGroup"                                   = "1001"
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"

    labels = {
      app = "cert-manager"
    }
  }
}

data "aws_route53_zone" "this" {
  name = "refractr.mozit.cloud"
}

data "aws_iam_policy_document" "cert_manager" {
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${data.aws_route53_zone.this.id}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZonesByName",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:GetChange",
    ]
    resources = [
      "arn:aws:route53:::change/*"
    ]
  }
}

resource "aws_iam_policy" "cert_manager" {
  name_prefix = "${local.cert_manager_name_prefix}-policy-"
  path        = "/"
  description = "IAM Policy for cert-manager on ${module.itse-apps-stage-1.cluster_id}"
  policy      = data.aws_iam_policy_document.cert_manager.json
}

module "cert_manager_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.3"
  create_role                   = true
  role_name                     = "${local.cert_manager_name_prefix}-role"
  provider_url                  = replace(module.itse-apps-stage-1.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cert_manager.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.cert_manager_namespace}:cert-manager"]
  tags                          = { Name = "${local.cert_manager_name_prefix}-role" }
}

# CRDs have to be installed differently, there is a drama about it in the community.
# TL;DR: Helm is not yet ready to upgrade CRDs and this can cause an outage.
# For more info read https://github.com/helm/helm/issues/7735
resource "null_resource" "cert_manager_crd" {
  provisioner "local-exec" {
    working_dir = path.module
    command     = <<EOF
for i in `seq 1 10`; do \
  echo $kube_config | base64 --decode > kube_config.yaml & \
  kubectl apply --validate=false -f ${local.cert_manager_crd_manifest} --kubeconfig kube_config.yaml && break ||
  sleep 10; \
done; \
rm kube_config.yaml;
EOF
    interpreter = ["/bin/bash", "-c"]
    environment = {
      kube_config = base64encode(module.itse-apps-stage-1.kubeconfig)
    }
  }

  triggers = {
    endpoint = module.itse-apps-stage-1.cluster_endpoint
    version  = local.cert_manager_version
  }

  depends_on = [
    module.itse-apps-stage-1,
    helm_release.cert_manager
  ]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = local.cert_manager_version

  dynamic "set" {
    iterator = item
    for_each = local.cert_manager_settings

    content {
      name  = item.key
      value = item.value
    }
  }
}
