# 1. Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# 2. The Launch Template (The Blueprint)
resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project_name}-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  # Attach the IAM Profile so EC2 can talk to Secrets Manager
  iam_instance_profile {
    name = var.iam_instance_profile
  }

  # Security Group (Allow HTTP from ALB)
  vpc_security_group_ids = [var.app_sg_id]

  # INJECT THE USER DATA SCRIPT
  # We read the file and replace the ${variables} with real values
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    secret_name = var.secret_name
    region      = "ap-south-1"
    db_endpoint = var.db_endpoint
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-app-server"
    }
  }
}

# 3. The Auto Scaling Group (The Manager)
resource "aws_autoscaling_group" "app_asg" {
  name                = "${var.project_name}-asg"
  desired_capacity    = 2
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = var.private_subnet_ids # Launch in Private App Subnets

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  # Connect to the Load Balancer (We will add this variable later)
  target_group_arns = [var.target_group_arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }
}
