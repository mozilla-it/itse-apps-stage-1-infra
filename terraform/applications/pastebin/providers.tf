provider "aws" {
  region = var.region

  default_tags {
    tags = {
      CostCenter    = var.cost_center
      Environment   = var.environment
      Project       = var.project
      Project-Desc  = var.project_desc
      Project-Email = var.project_email
      Region        = var.region
      Terraform     = "true"
    }
  }
}
