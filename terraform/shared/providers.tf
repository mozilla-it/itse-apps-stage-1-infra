provider "aws" {
  region = var.region

  # see https://github.com/hashicorp/terraform-provider-aws/issues/18311
  # Remove for a while to avoid trying to keep tagging on every tf plan
  #default_tags {
  #  tags = {
  #    CostCenter  = var.cost_center
  #    Environment = var.environment
  #    Region      = var.region
  #    Terraform   = "true"
  #  }
  #}
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.itse-apps-stage-1.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.itse-apps-stage-1.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.itse-apps-stage-1.token
}

provider "helm" {

  kubernetes {
    host                   = data.aws_eks_cluster.itse-apps-stage-1.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.itse-apps-stage-1.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.itse-apps-stage-1.token
  }
}

provider "random" {
}

provider "local" {
}
