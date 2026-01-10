variable "project_name" {
  description = "Name of the project, used for tagging resources"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC (e.g., 10.0.0.0/16)"
  type        = string
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "app_subnets_cidr" {
  description = "List of CIDR blocks for private application subnets"
  type        = list(string)
}

variable "data_subnets_cidr" {
  description = "List of CIDR blocks for private data subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of Availability Zones to use"
  type        = list(string)
}
