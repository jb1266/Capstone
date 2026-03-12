# Automated Three-Tier Web Application with CI/CD Pipeline

A highly automated, security-focused three-tier web application deployed on AWS with a fully integrated CI/CD pipeline that triggers deployments on GitHub updates and Auto Scaling Group (ASG) EC2 instance creations.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Infrastructure](#infrastructure)
- [CI/CD Pipeline](#cicd-pipeline)
- [Application Stack](#application-stack)
- [Security](#security)
- [Auto Scaling & SSM Integration](#auto-scaling--ssm-integration)
- [Deployment Scripts](#deployment-scripts)

---

## Overview

This project provisions a production-ready Node.js web application on AWS that is:

- **Highly Automated** — New EC2 instances created by Auto Scaling automatically trigger the CI/CD pipeline via AWS Systems Manager (SSM) State Manager
- **Database Ready** — Application is configured with MySQL2 and ready to connect to a database tier
- **Security Focused** — Web servers run in private subnets, accessible only through an internet-facing Application Load Balancer (ALB) protected by AWS WAF, Security Groups, and Network ACLs (NACLs)
- **Highly Available** — Deployed across two Availability Zones with Auto Scaling to handle variable load

---

## Architecture

```
                        Internet
                           │
                           ▼
                    ┌─────────────┐
                    │  AWS WAF    │
                    └─────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │  Application Load      │
              │  Balancer (Port 80)    │
              │  [Public Subnets]      │
              └────────────────────────┘
                    │           │
          ┌─────────┘           └─────────┐
          ▼                               ▼
   ┌─────────────┐                 ┌─────────────┐
   │  AZ 1       │                 │  AZ 2       │
   │  Public     │                 │  Public     │
   │  Subnet     │                 │  Subnet     │
   └─────────────┘                 └─────────────┘
   ┌─────────────┐                 ┌─────────────┐
   │  Private    │                 │  Private    │
   │  Subnet 1   │                 │  Subnet 1   │
   │  [EC2/ASG]  │                 │  [EC2/ASG]  │
   └─────────────┘                 └─────────────┘
   ┌─────────────┐                 ┌─────────────┐
   │  Private    │                 │  Private    │
   │  Subnet 2   │                 │  Subnet 2   │
   └─────────────┘                 └─────────────┘
```

---

## Infrastructure

### VPC & Networking

| Component | Configuration |
|---|---|
| Availability Zones | 2 |
| Public Subnets | 1 per AZ (2 total) — ALB |
| Private Subnets | 2 per AZ (4 total) — EC2 instances |
| Internet Gateway | Attached to VPC for ALB |
| NACLs | Applied to both public and private subnets |

### Load Balancer

- **Type:** Internet-facing Application Load Balancer (ALB)
- **Placement:** Public subnets across both Availability Zones
- **Listener:** Port 80 (HTTP)
- **Target Group:** Routes traffic to EC2 instances in private subnets
- **Health Checks:** Enabled on the target group

### Auto Scaling Group

- **Name:** `capstone-auto-scaling`
- **Placement:** Private subnets across Availability Zones
- **Health Checks:** Enabled
- **Instance Tag:** `Key: Environment` / `Value: Prod`
- **Trigger:** New instance launches automatically invoke the CI/CD pipeline via SSM State Manager

---

## CI/CD Pipeline

### Pipeline Overview

```
GitHub (Source)
      │
      ▼
AWS CodePipeline
      │
      ├── Source Stage      ← Triggered by GitHub push
      │
      └── Deploy Stage      ← CodeDeploy to SSM Managed EC2 instances
                               (Tag: Environment = Prod)
```

### Trigger Conditions

The pipeline is triggered in two scenarios:

1. **GitHub Push** — Any push to the connected GitHub repository automatically starts the pipeline
2. **New ASG Instance** — When Auto Scaling launches a new EC2 instance, SSM State Manager detects it and triggers the pipeline to deploy the latest application code

### CodeDeploy Configuration

- **Deployment Target:** SSM Managed Nodes with tag `Key=Environment`, `Value=Prod`
- **AppSpec:** Managed via `appspec.yml` in the repository root
- **Lifecycle Hooks:** `install_dependencies.sh` and `start_server.sh`

---

## Application Stack

| Component | Technology |
|---|---|
| Runtime | Node.js |
| Process Manager | PM2 |
| Reverse Proxy | Caddy |
| Database Driver | MySQL2 |
| Package Manager | npm |

### How It Works

1. Caddy reverse proxies incoming traffic from **port 80 → port 3000** where the Node.js app listens
2. PM2 manages the Node.js process, keeping it alive and restarting it on failure
3. MySQL2 is installed and ready to connect to a database tier
4. The private IP address of each EC2 instance is dynamically written to `index.html` at startup

---

## Security

### Layers of Security

| Layer | Implementation |
|---|---|
| WAF | AWS WAF attached to the ALB — filters malicious traffic |
| Security Groups | Separate SGs for ALB and EC2 instances with least-privilege rules |
| NACLs | Applied to public and private subnets as an additional network filter |
| Private Subnets | EC2 instances are not directly internet-accessible |
| ALB | Only entry point for external traffic into the application tier |

### Security Group Rules (Summary)

**ALB Security Group**
- Inbound: Port 80 from `0.0.0.0/0`
- Outbound: Port 3000 to EC2 Security Group

**EC2 Security Group**
- Inbound: Port 3000 from ALB Security Group only
- Inbound: SSM traffic (no SSH required)
- Outbound: Required AWS service endpoints

---

## Auto Scaling & SSM Integration

### How New Instances Trigger the Pipeline

```
New EC2 instance launches (ASG)
           │
           ▼
SSM State Manager detects new instance
(targets tag: ASGName = capstone-auto-scaling)
           │
           ▼
SSM Document runs on instance
           │
           ├── Waits for PM2 app to be online
           │
           └── Triggers AWS CodePipeline
                    │
                    ▼
             CodeDeploy deploys
             latest application
             code to new instance
```

### SSM Document

The SSM Document (`AppDeployDocument`) runs the following steps on each new instance:

1. Retrieves the EC2 Instance ID from instance metadata (IMDSv2)
2. Waits for the PM2-managed application to come online (polling every 15 seconds, up to 6 minutes)
3. Triggers `capstone-pipeline-test` via the AWS CodePipeline API

### State Manager Association

- **Target Tag:** `Key: ASGName` / `Value: capstone-auto-scaling`
- **Schedule:** Runs on a defined interval to catch any new instances
- **Concurrency:** Rolling execution with max concurrency and error thresholds to protect fleet stability

---

## Deployment Scripts

### `install_dependencies.sh`

Runs during the **Install** lifecycle hook of CodeDeploy. Installs all required software on the EC2 instance:

- `unzip` — Required for AWS CLI installation
- `AWS CLI` — For interacting with AWS services from the instance
- `SSM Agent` — Enables Systems Manager connectivity (installed via snap)
- `Node.js` + `npm` — Application runtime
- `PM2` — Node.js process manager
- `MySQL2` — Database driver (npm package)
- `Caddy` — Reverse proxy web server
- npm dependencies from `package.json`

### `start_server.sh`

Runs during the **Start** lifecycle hook of CodeDeploy. Configures and starts all services:

- Writes the Caddy configuration to reverse proxy port 80 → port 3000
- Injects the EC2 instance's private IP address into `index.html`
- Starts/restarts the Node.js application via PM2
- Starts/restarts the Caddy web server

---

## Repository Structure

```
├── appspec.yml                  # CodeDeploy deployment configuration
├── scripts/
│   ├── install_dependencies.sh  # Installs all required software
│   ├── start_server.sh          # Configures and starts the application
│   ├── stop_server.sh           # Stops PM2
│   └── validate_service.sh      # Checks if server is running
├── Public                       # Contains main HTML file (IP injected at runtime)
├── app.js                       # Node.js application entry point
└── package.json                 # npm dependencies
```