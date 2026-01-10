variable "project_name" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "app_sg_id" { type = string }
variable "target_group_arn" { type = string }

# Variables for User Data
variable "iam_instance_profile" { type = string }
variable "secret_name" { type = string }
variable "db_endpoint" { type = string }
