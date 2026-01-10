variable "project_name" {
  description = "Name of the project, used for naming the Security Groups"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where these Security Groups will be created"
  type        = string
}
