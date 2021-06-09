locals {
  cluster_features = {
    "prometheus"         = true
    "external_secrets"   = true
    "flux"               = true
    "flux_helm_operator" = true
    "aws_calico"         = true
    "prometheus"         = true
  }

  flux_settings = {
    "git.url"          = "git@github.com:mozilla-it/itse-apps-stage-1-infra"
    "git.branch"       = "main"
    "git.pollInterval" = "1m"
  }

  external_secrets_settings = {
    secrets_path = "/stage/*"
  }

  subnet_az = [for s in data.aws_subnet.public : s.availability_zone]
  subnet_id = [for s in data.aws_subnet.public : s.id]

  node_groups = {
    default_node_group = {
      name             = "itse-apps-stage-1-default_node_group-fluent-tahr"
      desired_capacity = 3,
      min_capacity     = 3,
      max_capacity     = 10,
      instance_types   = ["t3.large"],
      disk_size        = 100,
      subnets          = data.terraform_remote_state.vpc.outputs.public_subnets
    }
  }
}

module "itse-apps-stage-1" {
  source                    = "github.com/mozilla-it/terraform-modules//aws/eks?ref=d9a7662d464cd395d87fbc26a0682a50c4fb208f"
  cluster_name              = "itse-apps-stage-1"
  cluster_version           = "1.18"
  vpc_id                    = data.terraform_remote_state.vpc.outputs.vpc_id
  cluster_subnets           = data.terraform_remote_state.vpc.outputs.public_subnets
  cluster_features          = local.cluster_features
  node_groups               = local.node_groups
  flux_settings             = local.flux_settings
  external_secrets_settings = local.external_secrets_settings
  admin_users_arn           = ["arn:aws:iam::783633885093:role/maws-admin", "arn:aws:iam::517826968395:role/itsre-admin"]
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
