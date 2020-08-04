locals {
  cluster_features = {
    "flux"               = true
    "flux_helm_operator" = true
    "external_secrets"   = true
    "aws_calico"         = true
  }

  flux_settings = {
    "git.url"    = "git@github.com:mozilla-it/itse-apps-stage-1-infra"
    "git.branch" = "main"
  }
}

module "itse-apps-stage-1" {
  source                        = "github.com/mozilla-it/terraform-modules//aws/eks?ref=master"
  cluster_name                  = "itse-apps-stage-1"
  cluster_version               = "1.17"
  vpc_id                        = data.terraform_remote_state.vpc.outputs.vpc_id
  cluster_subnets               = data.terraform_remote_state.vpc.outputs.public_subnets
  cluster_features              = local.cluster_features
  flux_settings                 = local.flux_settings
  external_secrets_secret_paths = ["/stage/*"]
  admin_users_arn               = ["arn:aws:iam::783633885093:role/maws-admin", "arn:aws:iam::517826968395:role/itsre-admin"]
}
