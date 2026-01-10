variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "vegan-studio"
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
}

variable "public_subnets_cidr" {
  description = "Public Subnet CIDRs"
  type        = list(string)
}

variable "app_subnets_cidr" {
  description = "App Subnet CIDRs"
  type        = list(string)
}

variable "data_subnets_cidr" {
  description = "Data Subnet CIDRs"
  type        = list(string)
}

variable "availability_zones" {
  description = "AZs"
  type        = list(string)
}
