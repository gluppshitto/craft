terraform {
  required_version = "=1.4.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "birdie-terraform-state-184033899482"
    region = "eu-west-2"
    key    = "h-test-server.tfstate"
  }
}

locals {
  account_id = "184033899482"
}

provider "aws" {
  region = "eu-west-2"
}
