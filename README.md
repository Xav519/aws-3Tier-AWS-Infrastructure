# 🚀 Enterprise-Grade 3-Tier Cloud Infrastructure
### High-Availability "Goal Tracker" Deployment on AWS via Terraform

This repository contains the complete Infrastructure as Code (IaC) for a secure, scalable, and highly available 3-tier web application. It features a **React** frontend, a **Go** (Golang) REST API, and a **PostgreSQL** RDS database, all orchestrated within a custom-designed AWS VPC across multiple Availability Zones.



---

## 🏗️ The Architecture Stack
* **Infrastructure:** Terraform (Modularized)
* **Cloud Provider:** AWS (Global Infrastructure)
* **Compute:** EC2 Auto Scaling Groups (Frontend & Backend)
* **Database:** AWS RDS PostgreSQL 15.x (Multi-AZ Deployment)
* **Networking:** VPC, NAT Gateways, Internet Gateway, 2x Application Load Balancers
* **Security:** AWS Secrets Manager, IAM Roles (Least Privilege), Bastion Host, Security Groups
* **Application:** Dockerized Go (Backend) & React/HTML (Frontend)

---

## 🛰️ Technical Deep Dive

### 1. Networking & High Availability
The VPC is architected across multiple Availability Zones to ensure zero downtime.
* **Public Subnets:** Host the **External ALB** and a hardened **Bastion Host**.
* **Presentation Subnets (Private):** Host the Frontend ASG. Users connect via the External ALB; instances have no public IPs.
* **Logic Subnets (Private):** Host the Backend ASG and the **Internal ALB**. This ensures the API tier is never exposed to the public internet.
* **Database Subnets (Private):** Host the RDS instance, isolated from all tiers except the Logic Tier via strict Security Group rules.

### 2. Security & Secret Management
Instead of hardcoded credentials, this project utilizes **Dynamic Secret Injection**:
* **Terraform `random_password`:** Generates a 16-character complex password at runtime with specific character overrides for DB compatibility.
* **AWS Secrets Manager:** Stores the generated password and RDS endpoint. 
* **IAM Instance Profiles:** The Backend EC2s use an IAM role to "fetch" their own credentials at boot using the AWS CLI/SDK, removing the need for local `.env` files or hardcoded strings.

### 3. Self-Healing Compute
Both the Frontend and Backend are wrapped in **Auto Scaling Groups**. If an instance fails a health check on the `/goals` endpoint, the ALB automatically drains traffic, and the ASG terminates and replaces the instance.



---

## 📸 Project Verification (Proof of Work)

### I. Application Functionality
The full stack communication is verified here. The user adds a goal on the UI, which travels through two Load Balancers and is written to the persistent RDS layer.

> **[INSERT SCREENSHOT: Your website browser window showing "Goal Added Successfully" with the ALB URL visible]**

### II. Infrastructure Health & Target Groups
This view confirms that the AWS health checks are passing across multiple AZs.


> **[INSERT SCREENSHOT: Your AWS Console showing both Target Groups with "Healthy" status]**

### III. Secure Administrative Access
To prove private subnet isolation, access is performed via the Bastion Host. Below shows the logs of the Go backend successfully handshaking with the RDS instance using Secrets Manager credentials.

> **[INSERT SCREENSHOT: Your terminal showing the SSH hop from Bastion to Backend + `docker logs` output showing "Connected to Database"]**

---

## 🚀 Deployment Guide

### 1. Initialize & Workspace Setup
```
terraform init
```

### 2. Preview Changes
```
terraform plan
```

### 3. Apply Infrastructure
```
terraform apply
```

### 4. Cleanup
```
terraform destroy
```

## 💡 Key Design Decisions
* **Why Internal ALB?** To prevent "Side-Channel" attacks. The API is only reachable from within the VPC, providing an extra layer of security.
* **Why Multi-AZ RDS?** To provide high availability. If the primary DB fails, AWS flips the DNS to the standby in seconds with zero manual intervention.
* **Why SSM Managed Policy?** To allow for terminal access via the AWS Console (Session Manager), reducing the attack surface of Port 22 and eliminating the need to manage SSH keys globally.

# 👨‍💻 Author

Xavier Dupuis\
At this time, I have:\
Bachelor in Cybersecurity - May 2026\
AWS Certified Cloud Practitioner\
AWS Certified Solutions Architect -- Associate\
AWS Certified Security -- Specialty
[...]

------------------------------------------------------------------------

This project demonstrates secure, scalable, and production-ready AWS
infrastructure by design.