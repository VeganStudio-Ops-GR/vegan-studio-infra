variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }

# This is the password from Secrets Manager
variable "db_password" {
  type      = string
  sensitive = true
}

# This is the Missing Piece!
variable "db_sg_id" {
  type = string
}
