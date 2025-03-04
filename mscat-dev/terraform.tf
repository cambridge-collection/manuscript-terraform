terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "> 2.3.0"
    }
  }

  backend "s3" {
    bucket         = "sandbox-cudl-terraform-state"
    key            = "sandbox-mscat-dev-infra.tfstate"
    dynamodb_table = "terraform-state-lock-cudl"
    region         = "eu-west-1"
  }

  required_version = "~> 1.9.7"
}
