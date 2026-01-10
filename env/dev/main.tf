module "vpc" {
  # NOTICE: The path now goes UP two levels (../../) to find modules
  source = "../../modules/vpc"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnets_cidr = var.public_subnets_cidr
  app_subnets_cidr    = var.app_subnets_cidr
  data_subnets_cidr   = var.data_subnets_cidr
  availability_zones  = var.availability_zones
}

module "sg" {
  source = "../../modules/sg"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}
# MODULE 3: IAM Role (Security)
module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
}

# MODULE 4: Secrets Manager (Database Password)
module "secrets" {
  source       = "../../modules/secrets"
  project_name = var.project_name
}
