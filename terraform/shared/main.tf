locals {
  cluster_features = {
    "aws_calico"         = true
    "external_secrets"   = true
    "fluentd_papertrail" = false
    "flux"               = true
    "flux_helm_operator" = true
    "prometheus"         = true
    "configmapsecrets"   = true
  }

  external_secrets_settings = {}

  # fluentd_papertrail_settings = {
  #   "externalSecrets.secretsKey" = "/stage/${module.itse-apps-stage-1.cluster_id}-papertrail"
  # }

  flux_settings = {
    "git.url"    = "git@github.com:mozilla-it/itse-apps-stage-1-infra"
    "git.branch" = "main"
  }

  node_groups = {
    green_node_group = {
      # For reference
      # AMI versions: https://docs.aws.amazon.com/eks/latest/userguide/eks-linux-ami-versions.html
      release_version  = "1.21.5-20220123"
      desired_capacity = 3,
      disk_size        = 100,
      instance_types   = ["t3.large"],
      max_capacity     = 10,
      min_capacity     = 3,
      subnets          = data.terraform_remote_state.vpc.outputs.private_subnets
    }
  }

  subnet_az = [for s in data.aws_subnet.public : s.availability_zone]
  subnet_id = [for s in data.aws_subnet.public : s.id]
}

module "itse-apps-stage-1" {
  source                    = "github.com/mozilla-it/terraform-modules//aws/eks?ref=master"
  cluster_name              = "itse-apps-stage-1"
  admin_users_arn           = ["arn:aws:iam::783633885093:role/maws-admin", "arn:aws:iam::517826968395:role/itsre-admin"]
  cluster_features          = local.cluster_features
  cluster_subnets           = data.terraform_remote_state.vpc.outputs.public_subnets
  cluster_version           = "1.19"
  enable_logging            = true
  external_secrets_settings = local.external_secrets_settings
  external_secrets_prefixes = ["/dev/*", "/stage/*"]
  flux_settings             = local.flux_settings
  node_groups               = local.node_groups
  vpc_id                    = data.terraform_remote_state.vpc.outputs.vpc_id
  # fluentd_papertrail_settings = local.fluentd_papertrail_settings
  prometheus_settings = {}
  prometheus_customization_settings = {
    "influxdb.enabled" : "true"
    "influxdb.secret_key" : "/stage/influxdb/stage"
  }
  influxdb = true
}

# Chicken and egg issue, this needs to exist first
# before we can create the refractr ingress-nginx
resource "aws_eip" "refractr_eip" {
  count = length(local.subnet_az)
  vpc   = true

  tags = {
    Name     = "refractr-stage-${local.subnet_az[count.index]}"
    SubnetId = local.subnet_id[count.index]
    App      = "refractr"
  }
}
