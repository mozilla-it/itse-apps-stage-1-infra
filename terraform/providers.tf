provider "aws" {
  region  = var.region
  version = ">= 2.7.0"
}

provider "kubernetes" {
  alias                  = "itse-apps-stage-1"
  version                = ">= 1.11.4"
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks.token
  load_config_file       = false
}

provider "random" {
  version = "~> 2"
}

provider "local" {
}
