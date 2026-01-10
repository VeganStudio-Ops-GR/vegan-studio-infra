module "vpc" {
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

# MODULE 5: S3 Bucket (Artifacts)
module "s3" {
  source       = "../../modules/s3"
  project_name = var.project_name
  env          = "prod" # <--- Crucial change: "prod" instead of "dev"
}

# MODULE 6: RDS Database (MySQL)
module "rds" {
  source       = "../../modules/rds"
  project_name = var.project_name

  # Network Connections
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.data_subnet_ids

  # Security Connection
  db_password = module.secrets.db_password_value
}
