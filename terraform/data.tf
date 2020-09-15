# This assume your vpc_id output is called vpc_id
data "aws_vpc" "this" {
  id = data.terraform_remote_state.vpc.outputs.vpc_id
}

data "aws_subnet" "public" {
  for_each = toset(data.terraform_remote_state.vpc.outputs.public_subnets)
  id       = each.value
}

data "aws_eks_cluster" "itse-apps-stage-1" {
  name = module.itse-apps-stage-1.cluster_id
}

data "aws_eks_cluster_auth" "itse-apps-stage-1" {
  name = module.itse-apps-stage-1.cluster_id
}

data "aws_caller_identity" "current" {}
