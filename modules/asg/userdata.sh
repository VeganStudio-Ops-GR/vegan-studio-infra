#!/bin/bash
# Send logs to CloudWatch/Local for debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/null) 2>&1

echo "--- STARTING PROVISIONING ---"

# 1. Basics
yum update -y
yum install -y httpd php

# 2. Wait for the application code to exist
# If you are syncing from S3, wait until index.html is present
MAX_RETRIES=10
COUNT=0
while [ ! -f /var/www/html/index.html ] && [ $COUNT -lt $MAX_RETRIES ]; do
    echo "Waiting for /var/www/html/index.html to be deployed... ($COUNT)"
    sleep 5
    ((COUNT++))
done

# 3. Apply the Green Re-skin only if file exists
if [ -f /var/www/html/index.html ]; then
    echo "Applying Green Watermark..."
    
    # Update Slogan
    sed -i 's/Celebrating Plant-based Goodness/🟢 DEV ENVIRONMENT: GREEN FLEET ACTIVE/g' /var/www/html/index.html
    
    # Update Banner
    sed -i 's/Submit your favorite Vegan Recipes/TESTING BLUE-GREEN SWAP v2.0/g' /var/www/html/index.html
    
    # Update Contest Header
    sed -i 's/Vegan Studio Contest/DEV VALIDATION MODE/g' /var/www/html/index.html
    
    # Force Button to Success (Green)
    sed -i 's/btn-primary/btn-success/g' /var/www/html/index.html
else
    echo "ERROR: index.html not found after waiting. Sed commands skipped."
fi

# 4. Permissions & Start
chown -R apache:apache /var/www/html
systemctl restart httpd
systemctl enable httpd

echo "--- PROVISIONING COMPLETE ---"