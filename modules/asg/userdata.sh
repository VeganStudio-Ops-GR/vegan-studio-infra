#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/null) 2>&1

echo "--- STARTING PROVISIONING ---"

# 1. Install dependencies
yum update -y
yum install -y httpd php git

# 2. Clean and Clone the Repo
# We delete existing html content to ensure a clean clone
rm -rf /var/www/html/*
cd /var/www/html

# CLONE STEP: We use the '.' to put the files directly in /var/www/html/
git clone https://github.com/VeganStudio-Ops-GR/vegan-studio-app.git .

# 3. Apply the Green Re-skin (Now the files ACTUALLY exist)
echo "Applying Green Watermark to index.html..."

# Update Slogan
sed -i 's/Celebrating Plant-based Goodness/🟢 DEV ENVIRONMENT: GREEN FLEET ACTIVE/g' index.html

# Update Banner
sed -i 's/Submit your favorite Vegan Recipes/TESTING BLUE-GREEN SWAP v2.0/g' index.html

# Update Contest Header
sed -i 's/Vegan Studio Contest/DEV VALIDATION MODE/g' index.html

# Force Button to Success (Green)
sed -i 's/btn-primary/btn-success/g' index.html

# 4. Permissions & Service Start
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html
systemctl restart httpd
systemctl enable httpd

echo "--- PROVISIONING COMPLETE ---"