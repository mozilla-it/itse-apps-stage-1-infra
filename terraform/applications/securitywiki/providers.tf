provider "aws" {
  region = var.region

  # see https://github.com/hashicorp/terraform-provider-aws/issues/18311
  default_tags {
    tags = {
      CostCenter    = var.cost_center
      Environment   = var.environment
      Name          = "${var.project}-${var.environment}"
      Project       = var.project
      Project-Desc  = var.project_desc
      Project-Email = var.project_email
      Region        = var.region
      Terraform     = "true"
    }
  }
}
