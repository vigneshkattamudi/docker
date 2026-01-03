terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.25.0"
    }
  }

  backend "s3" {
    bucket       = "dsops84-roboshop-dev"
    key          = "roboshop-dev-docker"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  #Configuration options
  region = "us-east-1"
}