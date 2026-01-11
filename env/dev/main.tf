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
  env          = "dev"
}

module "rds" {
  source       = "../../modules/rds"
  project_name = var.project_name

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.data_subnet_ids

  # Injecting the Password from Secrets Module
  db_password = module.secrets.db_password_value

  # Injecting the Security Group from SG Module
  db_sg_id = module.sg.db_sg_id
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

  # App Configuration (User Data Injection)
  iam_instance_profile = module.iam.instance_profile_name
  secret_name          = module.secrets.secret_name
  db_endpoint          = module.rds.db_endpoint

  # --- NEW: Blue/Green Watermarking ---
  env_message = var.env_message
}

# ---------------------------------------------------------
# 1. FETCH PRODUCTION ALB (The "Blue" Environment)
# ---------------------------------------------------------
# This looks up your existing Prod ALB so we don't have to hardcode the DNS
data "aws_lb" "prod_alb" {
  name = "vegan-studio-prod-alb"
}

# ---------------------------------------------------------
# 2. CANARY DNS RECORDS (rajdevops.click)
# ---------------------------------------------------------

# THE BLUE PATH (90% Traffic to Production)
resource "aws_route53_record" "blue_primary" {
  zone_id = var.hosted_zone_id
  name    = "rajdevops.click"
  type    = "A"

  set_identifier = "blue-version-1"
  weighted_routing_policy {
    weight = 90
  }

  alias {
    name                   = data.aws_lb.prod_alb.dns_name
    zone_id                = data.aws_lb.prod_alb.zone_id
    evaluate_target_health = true
  }
}

# 1. Add this to look up your NEW Dev ALB dynamically
data "aws_lb" "dev_alb" {
  name = "vegan-studio-dev-alb" # Ensure this matches your Dev ALB name
}

# 2. Update the record to use the Data Source instead of the module
resource "aws_route53_record" "green_canary" {
  zone_id = var.hosted_zone_id
  name    = "rajdevops.click"
  type    = "A"

  set_identifier = "green-version-2"
  weighted_routing_policy {
    weight = 10
  }

  alias {
    name                   = data.aws_lb.dev_alb.dns_name
    zone_id                = data.aws_lb.dev_alb.zone_id # Use the data source attribute
    evaluate_target_health = true
  }
}


