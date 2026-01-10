# 1. The Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# NOTE: No aws_security_group resource here! We removed it!

# 2. The Database Instance
resource "aws_db_instance" "default" {
  identifier        = "${var.project_name}-db"
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  username          = "admin"
  password          = var.db_password
  db_name           = "vegandb"

  db_subnet_group_name = aws_db_subnet_group.default.name

  # CRITICAL: Use the variable we just added
  vpc_security_group_ids = [var.db_sg_id]

  skip_final_snapshot = true
  publicly_accessible = false
}
