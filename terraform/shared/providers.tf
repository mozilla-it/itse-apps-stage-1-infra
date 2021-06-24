provider "aws" {
  region  = var.region
  version = "~> 3"

  default_tags {
    tags = {
      Region      = var.region
      Environment = var.environment
      Terraform   = "true"
      CostCenter  = var.cost_center
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
