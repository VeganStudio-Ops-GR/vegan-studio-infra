# 1. LOAD BALANCER SECURITY GROUP (Public Facing)
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP/HTTPS from Internet"
  vpc_id      = var.vpc_id

  # Inbound: Allow HTTP (80) from Anywhere
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound: Allow HTTPS (443) from Anywhere
  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: Allow all traffic to go out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# 2. APPLICATION SECURITY GROUP (Private - Trusted by ALB)
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "Allow traffic only from ALB"
  vpc_id      = var.vpc_id

  # Inbound: Allow traffic ONLY from the ALB Security Group
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # <--- CHAINING
  }

  # Outbound: Allow all (needed for downloading updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}

# 3. DATABASE SECURITY GROUP (Private - Trusted by App)
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Allow traffic only from App Servers"
  vpc_id      = var.vpc_id

  # Inbound: Allow MySQL (3306) ONLY from App Security Group
  ingress {
    description     = "MySQL from App Servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id] # <--- CHAINING
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}
