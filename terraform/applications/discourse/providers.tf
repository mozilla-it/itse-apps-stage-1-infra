provider "aws" {
  region = local.workspace.region

  # see https://github.com/hashicorp/terraform-provider-aws/issues/18311
  default_tags {
    tags = {
      CostCenter    = local.workspace.cost_center
      Environment   = local.workspace.environment
      Project       = local.workspace.project
      Project-Desc  = local.workspace.project_desc
      Project-Email = local.workspace.project_email
      Region        = local.workspace.region
      Terraform     = "true"
    }
  }
}

# Needed for Cloudfront SSL cert
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  # see https://github.com/hashicorp/terraform-provider-aws/issues/18311
  default_tags {
    tags = {
      CostCenter    = local.workspace.cost_center
      Environment   = local.workspace.environment
      Project       = local.workspace.project
      Project-Desc  = local.workspace.project_desc
      Project-Email = local.workspace.project_email
      Region        = local.workspace.region
      Terraform     = "true"
    }
  }
}
