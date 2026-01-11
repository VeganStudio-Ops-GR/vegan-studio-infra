# 1. The Role (The "Identity")
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

# 2. The Policy (The "Permissions")
# We allow EC2 to:
# - Read Secrets (to get DB password)
# - Download from S3 (to get App Code)
resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.project_name}-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = "*" # In production, we would restrict this to specific ARNs
      }
    ]
  })
}

# 3. The Instance Profile (The "Badge" we attach to EC2)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# 4. Attach SSM Policy (For PEM-less access)
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 1. Attach the Managed Policy to your existing EC2 Role
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_role.name # Correct: Points to the resource above
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
