aws_region   = "ap-south-1"
project_name = "vegan-studio-dev" # Note: I added '-dev' so we can distinguish it in AWS!

vpc_cidr            = "10.0.0.0/16"
public_subnets_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
app_subnets_cidr    = ["10.0.10.0/24", "10.0.11.0/24"]
data_subnets_cidr   = ["10.0.20.0/24", "10.0.21.0/24"]
availability_zones  = ["ap-south-1a", "ap-south-1b"]
