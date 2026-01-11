#!/bin/bash

# ---------------------------------------------------------
# 1. INSTALLATION (LAMP Stack + Tools)
# ---------------------------------------------------------
# Update the package repository
dnf update -y

# Install Apache, PHP, MySQL Client, Git, and JQ (JSON Processor)
dnf install -y httpd php php-mysqli mariadb105 git jq

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Add ec2-user to apache group
usermod -a -G apache ec2-user

# ---------------------------------------------------------
# 2. DEPLOY CODE (Cloning your Repo)
# ---------------------------------------------------------
cd /var/www/html

# Clone your Organization Repo into the current directory (.)
git clone https://github.com/VeganStudio-Ops-GR/vegan-studio-app.git .

# Fix Permissions (Crucial for PHP to run correctly)
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# ---------------------------------------------------------
# 3. AUTOMATION (Secrets & Config)
# ---------------------------------------------------------

# A. FETCH PASSWORD FROM SECRETS MANAGER
# We use the AWS CLI to get the secret created by Terraform
# Terraform replaces ${secret_name} and ${region} with real values
DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${secret_name} --query SecretString --output text --region ${region})

# B. INJECT CONFIGURATION INTO db.php
# We use 'sed' to find the placeholders in the code and replace them with real AWS values.

# Replace Endpoint
sed -i "s/'Enter Your Database Endpoint DNS Name Here'/'${db_endpoint}'/g" db.php

# Replace Username (Hardcoded 'admin' in our RDS module)
sed -i "s/'Enter Your Database Username'/'admin'/g" db.php

# Replace Password (The one we just fetched from Secrets Manager)
sed -i "s/'Enter Your Database Password'/'$DB_PASSWORD'/g" db.php

# Replace DB Name (Hardcoded 'vegandb' in our RDS module)
sed -i "s/'Enter Your Database Name'/'vegandb'/g" db.php

# ---------------------------------------------------------
# 4. FINAL RESTART
# ---------------------------------------------------------

sudo yum update -y

# 2. Install the CloudWatch Agent package from the Amazon Linux repositories
sudo yum install amazon-cloudwatch-agent -y
systemctl restart httpd