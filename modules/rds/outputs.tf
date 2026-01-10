output "db_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "db_name" {
  value = aws_db_instance.default.db_name
}
