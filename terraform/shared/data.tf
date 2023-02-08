data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "itsre-state-783633885093"
    key    = "terraform/deploy.tfstate"
    region = "eu-west-1"
  }
}

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
