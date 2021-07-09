provider "aws" {
  region  = var.region
  version = "~> 3"

  # see https://github.com/hashicorp/terraform-provider-aws/issues/18311
  default_tags {
    tags = {
      CostCenter  = var.cost_center
      Environment = var.environment
      Region      = var.region
      Terraform   = "true"
    }
  }
}

provider "kubernetes" {
  version                = "~> 2"
  host                   = data.aws_eks_cluster.itse-apps-stage-1.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.itse-apps-stage-1.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.itse-apps-stage-1.token
}

provider "helm" {
  version = "~> 2"

  kubernetes {
    host                   = data.aws_eks_cluster.itse-apps-stage-1.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.itse-apps-stage-1.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.itse-apps-stage-1.token
  }
}

provider "random" {
  version = "~> 2"
}

provider "local" {
}
