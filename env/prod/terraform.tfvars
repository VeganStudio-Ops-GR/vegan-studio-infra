aws_region   = "ap-south-1"
project_name = "vegan-studio-prod"

# NEW CIDR BLOCK (10.1.x.x) - No conflict with Dev (10.0.x.x)
vpc_cidr = "10.1.0.0/16"

# Public Subnets (10.1.1.x, 10.1.2.x)
public_subnets_cidr = ["10.1.1.0/24", "10.1.2.0/24"]

# App Subnets (10.1.10.x, 10.1.11.x)
app_subnets_cidr = ["10.1.10.0/24", "10.1.11.0/24"]

# Data Subnets (10.1.20.x, 10.1.21.x)
data_subnets_cidr = ["10.1.20.0/24", "10.1.21.0/24"]

availability_zones = ["ap-south-1a", "ap-south-1b"]

# env/prod/terraform.tfvars
env_message = "Welcome to Vegan Studio - BLUE ENVIRONMENT (PROD)"
