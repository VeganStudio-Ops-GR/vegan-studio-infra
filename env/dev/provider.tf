provider "aws" {
  region = var.aws_region

}
# ADD THIS PART HERE
provider "aws" {
  alias  = "dns_account"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::506776019563:role/account-70-to-account63"
  }
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
