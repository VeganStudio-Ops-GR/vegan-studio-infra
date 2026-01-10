# 1. Generate a random password (16 chars, no weird symbols)
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# 2. Create the Vault (The Container)
resource "aws_secretsmanager_secret" "db_secret" {
  name = "${var.project_name}-db-password-${random_id.suffix.hex}"

  # Best Practice: Delete it immediately if we destroy terraform (7 days default)
  recovery_window_in_days = 0
}

# 3. Put the Password inside the Vault
resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = random_password.db_password.result
}

# 4. Random ID to ensure unique secret name if we destroy/recreate
resource "random_id" "suffix" {
  byte_length = 4
}
