provider "aws" {
  region  = var.region
  version = "~> 2"
}

provider "kubernetes" {
  version                = "~> 1"
  host                   = data.aws_eks_cluster.itse-apps-stage-1.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.itse-apps-stage-1.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.itse-apps-stage-1.token
  load_config_file       = false
}

provider "helm" {
  version = "~> 1"

  kubernetes {
    host                   = data.aws_eks_cluster.itse-apps-stage-1.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.itse-apps-stage-1.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.itse-apps-stage-1.token
    load_config_file       = false
  }
}

provider "random" {
  version = "~> 2"
}

provider "local" {
}
