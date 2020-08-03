terraform {
  required_version = ">= 0.12"
}

terraform {
  backend "s3" {
    bucket = "itse-apps-stage-1-state"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "itsre-state-783633885093"
    key    = "terraform/deploy.tfstate"
    region = "eu-west-1"
  }
}
