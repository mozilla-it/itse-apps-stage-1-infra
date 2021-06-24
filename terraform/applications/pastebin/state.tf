terraform {
  backend "s3" {
    bucket = "itsre-state-783633885093"
    key    = "us-west-2/pastebin/stage/terraform.tfstate"
    region = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 3.0"
    }
  }

  required_version = ">= 0.12"
}

data "terraform_remote_state" "deploy" {
  backend = "s3"

  config = {
    bucket = "itsre-state-783633885093"
    key    = "terraform/deploy.tfstate"
    region = "eu-west-1"
  }
}
