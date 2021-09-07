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

# some objects, like lambdas at edge, must be deployed in east
provider "aws" {
  alias  = "aws-east"
  region = "us-east-1"

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
