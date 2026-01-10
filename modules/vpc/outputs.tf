# 1. VPC ID
output "vpc_id" {
  value = aws_vpc.main.id
}

# 2. Public Subnets (for ALB)
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

# 3. App Subnets (for EC2 Application)
output "app_subnet_ids" {
  value = aws_subnet.private_app[*].id
}

# 4. Data Subnets (for RDS Database)
output "data_subnet_ids" {
  value = aws_subnet.private_data[*].id
}
