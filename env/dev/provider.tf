provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # PARTIAL CONFIGURATION: No hardcoded values here!
  # We will pass them during 'terraform init'
  backend "s3" {}
}
