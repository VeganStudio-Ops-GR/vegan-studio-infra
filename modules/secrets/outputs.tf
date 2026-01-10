output "secret_arn" {
  value = aws_secretsmanager_secret.db_secret.arn
}

output "secret_name" {
  value = aws_secretsmanager_secret.db_secret.name
}

output "db_password_value" {
  value     = random_password.db_password.result
  sensitive = true
}
