provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project       = var.project
      Region        = var.region
      Environment   = var.environment
      Terraform     = "true"
      CostCenter    = var.cost_center
      Project-Desc  = "paste.allizom.org"
      Project-Email = "it-sre@mozilla.com"
    }
  }
}
