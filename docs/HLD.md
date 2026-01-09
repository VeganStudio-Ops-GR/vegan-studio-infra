HIGH LEVEL DESIGN DOCUMENT
PROJECT: VEGAN STUDIO MIGRATION
AUTHOR: DEVOPS TEAM
DATE: JANUARY 2026

---

1. EXECUTIVE SUMMARY

---

The Vegan Studio is migrating from a manual "ClickOps" deployment to a fully
automated infrastructure using Terraform on AWS. The goal is to host a
scalable, highly available web application for the Recipe Contest.

---

2. ARCHITECTURE OVERVIEW: 3-TIER WEB APPLICATION

---

We will implement a standard 3-Tier architecture to ensure security and scalability.

A. TIER 1: PRESENTATION LAYER (PUBLIC)

- Component: Application Load Balancer (ALB)
- Subnets: Public Subnets (Accessible from the internet)
- Function: Distributes incoming HTTP/HTTPS traffic to the web servers.
  Handles SSL termination.

B. TIER 2: APPLICATION LAYER (PRIVATE)

- Component: EC2 Instances (Web Servers)
- Subnets: Private App Subnets (No direct internet access)
- Scaling: Auto Scaling Group (ASG) to handle traffic spikes.
- Security: Security Groups allowing traffic only from the ALB.

C. TIER 3: DATA LAYER (PRIVATE)

- Component: Amazon RDS (MySQL)
- Subnets: Private DB Subnets (Strictly isolated)
- Availability: Multi-AZ enabled for Disaster Recovery (Primary + Standby).

---

3. TECHNOLOGY STACK

---

- Infrastructure as Code: Terraform
- CI/CD: GitHub Actions
- Cloud Provider: AWS (Region: us-east-1)
- State Management: S3 (Remote Backend) + DynamoDB (Locking)
