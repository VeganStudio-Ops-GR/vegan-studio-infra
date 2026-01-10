# 1. The Subnet Group (Where the DB lives)
resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# 2. Security Group (The Firewall)
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow MySQL traffic from App"
  vpc_id      = var.vpc_id

  # Ingress: Allow traffic ONLY on port 3306
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In a real strict setup, we reference the App SG ID here.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. The Database Instance
resource "aws_db_instance" "default" {
  identifier        = "${var.project_name}-db"
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"
  engine_version    = "8.0" # Or 5.7 depending on your app requirement
  instance_class    = "db.t3.micro"
  username          = "admin"
  password          = var.db_password # Injected from Secrets Module
  db_name           = "vegandb"       # The initial database name

  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot = true # For lab/dev only (destroys faster)
  publicly_accessible = false
}
