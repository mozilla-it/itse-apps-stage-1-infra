terraform {
  backend "s3" {
    bucket = "itse-apps-stage-1-state"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}
