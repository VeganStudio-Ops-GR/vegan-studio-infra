#!/bin/bash

# ---------------------------------------------------------
# 1. INITIALIZATION & OBSERVABILITY (The "Control Room")
# ---------------------------------------------------------
# Update and install the agent first so we can monitor the rest of the boot process
dnf update -y
dnf install -y amazon-cloudwatch-agent jq git httpd php php-mysqli mariadb105

# Create the CloudWatch Agent configuration file immediately
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "vegan-studio-apache-errors",
            "log_stream_name": "{instance_id}",
            "retention_in_days": 7
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "vegan-studio-provisioning-logs",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"]
      }
    }
  }
}
EOF

# Start the CloudWatch agent now. 
# Even if the rest of this script fails, the agent will send the error logs to AWS.
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

# ---------------------------------------------------------
# 2. DEPLOY CODE & SECRETS (The "Engine")
# ---------------------------------------------------------
systemctl start httpd
systemctl enable httpd
usermod -a -G apache ec2-user

cd /var/www/html
git clone https://github.com/VeganStudio-Ops-GR/vegan-studio-app.git .

# Fetch Database Password from Secrets Manager
DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${secret_name} --query SecretString --output text --region ${region})

# Inject Configuration into db.php using sed
sed -i "s/'Enter Your Database Endpoint DNS Name Here'/'${db_endpoint}'/g" db.php
sed -i "s/'Enter Your Database Username'/'admin'/g" db.php
sed -i "s/'Enter Your Database Password'/'$DB_PASSWORD'/g" db.php
sed -i "s/'Enter Your Database Name'/'vegandb'/g" db.php

# Final Permissions Fix
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# Restart Apache to apply all changes
systemctl restart httpd