output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "app_subnets" {
  description = "List of IDs of private application subnets"
  value       = aws_subnet.private_app[*].id
}

output "data_subnets" {
  description = "List of IDs of private data subnets"
  value       = aws_subnet.private_data[*].id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "data_subnet_ids" {
  value = aws_subnet.private_data[*].id
}

# For App Layer (if needed later)
output "app_subnet_ids" {
  value = aws_subnet.private_app[*].id
}

# For Public Layer (ALB needs this)
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "vpc_id" {
  value = aws_vpc.main.id
}
