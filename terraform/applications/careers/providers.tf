provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Environment   = local.environment
      Project       = local.project
      Project-Desc  = local.project_desc
      Project-Email = local.project_email
      Region        = local.region
      Terraform     = "true"
    }
  }
}
