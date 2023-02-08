terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~>2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2"
    }

    local = {
      source = "hashicorp/local"
    }

    null = {
      source = "hashicorp/null"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}
