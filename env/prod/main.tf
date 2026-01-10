# ---------------------------------------------------------
# 1. NETWORK LAYER
# ---------------------------------------------------------
module "vpc" {
  source              = "../../modules/vpc"
  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnets_cidr = var.public_subnets_cidr
  app_subnets_cidr    = var.app_subnets_cidr
  data_subnets_cidr   = var.data_subnets_cidr
  availability_zones  = var.availability_zones
}

# ---------------------------------------------------------
# 2. SECURITY LAYER (Firewalls & Roles)
# ---------------------------------------------------------
module "sg" {
  source       = "../../modules/sg"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
}

module "secrets" {
  source       = "../../modules/secrets"
  project_name = var.project_name
}

# ---------------------------------------------------------
# 3. DATA LAYER (Storage & Database)
# ---------------------------------------------------------
module "s3" {
  source       = "../../modules/s3"
  project_name = var.project_name
  env          = "prod" # <--- IMPORTANT: "prod"
}

module "rds" {
  source       = "../../modules/rds"
  project_name = var.project_name

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.data_subnet_ids

  # Injecting Password & Security Group
  db_password = module.secrets.db_password_value
  db_sg_id    = module.sg.db_sg_id
}

# ---------------------------------------------------------
# 4. APPLICATION LAYER (ALB & ASG)
# ---------------------------------------------------------
module "alb" {
  source            = "../../modules/alb"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.sg.alb_sg_id
}

module "asg" {
  source       = "../../modules/asg"
  project_name = var.project_name

  # Network
  private_subnet_ids = module.vpc.app_subnet_ids
  app_sg_id          = module.sg.app_sg_id
  target_group_arn   = module.alb.target_group_arn

  # App Configuration
  iam_instance_profile = module.iam.instance_profile_name
  secret_name          = module.secrets.secret_name
  db_endpoint          = module.rds.db_endpoint
}
