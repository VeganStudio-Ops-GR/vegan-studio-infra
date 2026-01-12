🚀 Vegan Studio: Cross-Account Canary Infrastructure
This repository contains the Infrastructure as Code (IaC) for the Vegan Studio platform. It implements a highly available, secure, and automated Blue/Green (Canary) Deployment strategy on AWS using Terraform.

🏗️ Architecture Overview
The project leverages a multi-account AWS setup to separate DNS management from compute resources:

Global Content Delivery: AWS CloudFront with SSL termination via ACM Wildcard Certificates.

Traffic Engineering: Route 53 Weighted Routing (90/10 split) managed in a separate DNS account (Account 63).

Compute Layer: Dual Application Load Balancers (Prod & Dev) powering EC2 Auto-Scaling Groups across multiple Availability Zones.

Security: Private subnets for compute, strict Security Group hierarchies, and IAM least-privilege roles.

📂 Project Structure
The repository follows a modular and environment-based layout for scalability:

Plaintext

.
├── env
│ ├── dev # Development/Green Environment
│ └── prod # Production/Blue Environment (ACM, CDN, Monitoring)
├── modules # Reusable Terraform Components
│ ├── vpc # Networking (Public/Private Subnets, NATGW)
│ ├── alb # Application Load Balancers
│ ├── asg # Auto Scaling Groups & UserData
│ ├── cdn # CloudFront Distribution
│ ├── rds # Relational Database Service
│ └── sg # Security Group definitions
└── docs # High-Level Design (HLD) documentation
🛠️ Tech Stack & Tools
Terraform: Infrastructure Provisioning.

AWS: Cloud Services (VPC, EC2, CloudFront, Route 53, ACM).

GitHub Projects: Agile/Scrum task management.

CloudWatch: Observability (Metrics & Logs Insights).

🚀 Deployment & Verification

1. Provisioning
   Bash

cd env/prod
terraform init -backend-config=backend.conf
terraform apply 2. Canary Verification
We use a cache-busting loop to verify the 90/10 traffic split through the CDN:

Bash

for i in {1..20}; do
curl -s "https://www.rajdevops.click/?v=$RANDOM" | grep -i "FLEET"
done
📊 Observability
The project includes a comprehensive CloudWatch Dashboard that aggregates:

Request counts per ALB (Prod vs. Dev).

Healthy Host counts.

Logs Insights: Real-time frequency graphs of Canary fleet hits.

🤝 Contributors
Infrastructure & DevOps Lead: Gururaj Rathod (GR)

Project Code & Terraform: Rajesh Daswani
