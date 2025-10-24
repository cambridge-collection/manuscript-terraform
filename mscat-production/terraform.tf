terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
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
    bucket       = "terraform-state-cul-shared-services"
    key          = "mscat-medieval-production.tfstate"
    use_lockfile = true
    region       = "eu-west-1"
  }


  required_version = "~> 1.12.2"
}
