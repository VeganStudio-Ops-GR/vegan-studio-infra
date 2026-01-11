# 1. Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 2. The Launch Template
resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project_name}-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  vpc_security_group_ids = [var.app_sg_id]

  # THE FIX: Added env_message to the variables list below
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    secret_name = var.secret_name
    region      = "ap-south-1"
    db_endpoint = var.db_endpoint
    env_message = var.env_message
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-app-server"
    }
  }
}

# 3. The Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                = "${var.project_name}-asg"
  desired_capacity    = 2
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }
}
