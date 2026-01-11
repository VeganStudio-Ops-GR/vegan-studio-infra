# ---------------------------------------------------------
# 1. INFRASTRUCTURE MODULES
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

module "s3" {
  source       = "../../modules/s3"
  project_name = var.project_name
  env          = "dev"
}

module "rds" {
  source             = "../../modules/rds"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.data_subnet_ids
  db_password        = module.secrets.db_password_value
  db_sg_id           = module.sg.db_sg_id
}

# ---------------------------------------------------------
# 2. APPLICATION LAYER (ALB & ASG)
# ---------------------------------------------------------

module "alb" {
  source            = "../../modules/alb"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.sg.alb_sg_id
}

module "asg" {
  source               = "../../modules/asg"
  project_name         = var.project_name
  private_subnet_ids   = module.vpc.app_subnet_ids
  app_sg_id            = module.sg.app_sg_id
  target_group_arn     = module.alb.target_group_arn
  iam_instance_profile = module.iam.instance_profile_name
  secret_name          = module.secrets.secret_name
  db_endpoint          = module.rds.db_endpoint

  # Injects the watermark into the Green instances
  env_message = "🟢 DEV ENVIRONMENT: GREEN FLEET ACTIVE"
}

# ---------------------------------------------------------
# 3. DATA LOOKUPS (Finding the ALBs for DNS)
# ---------------------------------------------------------

data "aws_lb" "dev_alb" {
  name = "vegan-studio-dev-alb"
}

data "aws_lb" "prod_alb" {
  name = "vegan-studio-prod-alb"
}

# ---------------------------------------------------------
# 4. CANARY DNS RECORDS (rajdevops.click)
# ---------------------------------------------------------

# THE BLUE PATH (90% Weight)
resource "aws_route53_record" "blue_primary" {
  provider = aws.dns_account
  zone_id  = var.hosted_zone_id
  name     = "rajdevops.click"
  type     = "A"

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

# THE GREEN PATH (10% Weight)
resource "aws_route53_record" "green_canary" {
  provider = aws.dns_account
  zone_id  = var.hosted_zone_id
  name     = "rajdevops.click"
  type     = "A"

  set_identifier = "green-version-2"
  weighted_routing_policy {
    weight = 10
  }

  alias {
    name                   = data.aws_lb.dev_alb.dns_name
    zone_id                = data.aws_lb.dev_alb.zone_id
    evaluate_target_health = true
  }
}

# ---------------------------------------------------------
# 5. SUBDOMAIN FIX (WWW RECORD)
# ---------------------------------------------------------

# This fixes the NXDOMAIN error for www.rajdevops.click
resource "aws_route53_record" "www" {
  provider = aws.dns_account
  zone_id  = var.hosted_zone_id
  name     = "www.rajdevops.click"
  type     = "A"

  alias {
    name                   = "rajdevops.click"
    zone_id                = var.hosted_zone_id
    evaluate_target_health = true
  }
}
