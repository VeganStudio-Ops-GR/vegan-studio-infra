variable "aws_region" {
  description = "Region to deploy"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "public_subnets_cidr" {
  description = "Public Subnets"
  type        = list(string)
}

variable "app_subnets_cidr" {
  description = "App Subnets"
  type        = list(string)
}

variable "data_subnets_cidr" {
  description = "Data Subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "AZs"
  type        = list(string)
}
variable "env_message" {
  description = "Message to display on the home page"
  type        = string
}
