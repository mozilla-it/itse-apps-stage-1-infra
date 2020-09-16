locals {
  cluster_features = {
    "prometheus"         = true
    "external_secrets"   = true
    "flux"               = true
    "flux_helm_operator" = true
    "aws_calico"         = true
  }

  flux_settings = {
    "git.url"          = "git@github.com:mozilla-it/itse-apps-stage-1-infra"
    "git.branch"       = "main"
    "git.pollInterval" = "1m"
  }

  subnet_az = [for s in data.aws_subnet.public : s.availability_zone]
  subnet_id = [for s in data.aws_subnet.public : s.id]
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

resource "aws_eip" "refractr_eip" {
  count = length(local.subnet_az)
  vpc   = true

  tags = {
    Name        = "refractr-stage-${local.subnet_az[count.index]}"
    SubnetId    = local.subnet_id[count.index]
    App         = "refractr"
    Environment = "stage"
    Terraform   = "true"
  }
}
