# Scalable Web Application Infrastructure

This project implements a highly available and scalable **decoupled web application infrastructure** on AWS using Terraform. The architecture follows AWS best practices for security, scalability, and high availability with separate frontend and backend tiers.

## Architecture Diagram

![AWS Infrastructure Diagram](Scalable%20Web%20Application%20with%20ALB%20and%20Auto%20Scaling.png)

## Architecture Overview

```
Internet (Users)
      ↓ HTTP:80
🌐 Frontend ALB (Public)
      ↓ HTTP:80
🖥️ Frontend EC2 (Apache + HTML)
      ↓ API calls to backend ALB
⚙️ Backend ALB (Private)
      ↓ HTTP:8080
🔧 Backend EC2 (Node.js API)
      ↓ MySQL:3306
🗄️ RDS MySQL (Primary + Secondary)
```

## Infrastructure Components

### 1. Network Layer (VPC Module)
- **VPC**: 10.0.0.0/16 across 2 Availability Zones
- **Public Subnets**: 10.0.1.0/24 (us-east-1a), 10.0.2.0/24 (us-east-1b)
- **Private Subnets**: 10.0.101.0/24 (us-east-1a), 10.0.102.0/24 (us-east-1b)
- **NAT Gateways**: Per AZ for private subnet internet access
- **Internet Gateway**: For public subnet access

### 2. Frontend Tier
#### Frontend Load Balancer (Frontend ALB Module)
- **Internet-facing** Application Load Balancer
- Deployed in **public subnets**
- HTTP (80) listener
- Health checks for frontend instances
- Security group allowing HTTP/HTTPS from internet

#### Frontend Compute (Frontend EC2 Module)
- **Auto Scaling Group** (1-3 instances)
- **Apache web servers** with modern HTML interface
- Deployed in **public subnets**
- **IAM instance profile** for CloudWatch access
- CPU-based auto scaling (70% threshold)

### 3. Backend Tier
#### Backend Load Balancer (Backend ALB Module)
- **Internal** Application Load Balancer
- Deployed in **private subnets**
- HTTP (8080) listener for API traffic
- Health checks on `/api/health` endpoint
- Security group allowing traffic from frontend EC2

#### Backend Compute (Backend EC2 Module)
- **Auto Scaling Group** (1-3 instances)
- **Node.js API servers** with REST endpoints
- Deployed in **private subnets**
- **IAM instance profile** for CloudWatch access
- CPU-based auto scaling (70% threshold)

### 4. Database Layer (RDS Module)
- **MySQL 8.0** database engine
- **Multi-AZ deployment** (Primary + Secondary)
- Instance Class: **db.t3.micro**
- **Automated backups** (7-day retention)
- **Auto-scaling storage** (20GB → 100GB)
- Deployed in **private subnets**
- Security group allowing traffic from backend EC2 only

### 5. Security (Security Module)
- **5-tier security group architecture**:
  - Frontend ALB Security Group (Internet → Frontend ALB)
  - Frontend EC2 Security Group (Frontend ALB → Frontend EC2)
  - Backend ALB Security Group (Frontend EC2 → Backend ALB)
  - Backend EC2 Security Group (Backend ALB → Backend EC2)
  - RDS Security Group (Backend EC2 → RDS)

### 6. Identity & Access Management (IAM)
- **EC2 IAM Role** with policies for:
  - CloudWatch metrics publishing
  - Systems Manager access
  - CloudWatch Logs access
- **IAM Instance Profile** attached to both frontend and backend instances

### 7. Monitoring & Notifications (Monitoring Module)
- **CloudWatch Dashboard** with metrics for:
  - EC2 CPU utilization
  - ALB request count and response time
  - RDS CPU and connections
  - Application error rates
- **CloudWatch Alarms** for:
  - High CPU utilization (EC2 & RDS)
  - High response time (ALB)
  - Error rates (5XX responses)
- **SNS Topic** for email notifications
- **Email subscriptions** for alarm notifications

## Security Features

### 1. **Network Security**
- **Multi-tier architecture** with proper network isolation
- **Private subnets** for backend and database
- **NAT Gateways** for secure outbound internet access
- **Security group layering** with least privilege access

### 2. **Access Control**
- **Frontend ALB**: Internet-facing (public subnets)
- **Backend ALB**: Internal only (private subnets)
- **EC2 Instances**: Proper IAM roles and instance profiles
- **RDS**: Isolated in private subnets, backend access only

### 3. **Monitoring & Security**
- **CloudWatch monitoring** for all components
- **SNS notifications** for security and performance alerts
- **Multi-AZ deployment** for fault tolerance

## High Availability & Scalability

### **High Availability**
- **Multi-AZ deployment** across us-east-1a and us-east-1b
- **RDS Multi-AZ** with automatic failover
- **Auto Scaling Groups** for both frontend and backend
- **Multiple NAT Gateways** (one per AZ)

### **Auto Scaling**
- **Frontend**: 1-3 instances based on CPU utilization
- **Backend**: 1-3 instances based on CPU utilization
- **Target CPU threshold**: 70%
- **Health checks**: ELB-based with 300s grace period

### **Load Distribution**
- **Frontend ALB**: Distributes user traffic across frontend instances
- **Backend ALB**: Distributes API traffic across backend instances
- **Cross-AZ load balancing** enabled

## Application Architecture

### **Frontend Application**
- **Technology**: Apache + HTML5 + JavaScript
- **Features**: 
  - Modern responsive UI
  - API testing functionality
  - Real-time server information display

### **Backend API**
- **Technology**: Node.js + HTTP server
- **Endpoints**:
  - `GET /api/health` - Health check endpoint
  - `GET /api/*` - General API endpoints
- **Features**:
  - CORS enabled
  - JSON responses
  - Health monitoring

## Getting Started

### **Prerequisites**
```bash
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0 installed
- SSH key pair created in AWS (ALB_key)
```

### **Quick Deployment**
```bash
# 1. Clone and navigate to project
cd manara

# 2. Initialize Terraform
terraform init

# 3. Review the deployment plan
terraform plan

# 4. Deploy infrastructure (47 resources)
terraform apply

# 5. Get application URL
terraform output frontend_alb_dns_name
```

### **Post-Deployment Setup**
1. **Confirm SNS subscription** in your email
2. **Access the application** via Frontend ALB DNS name
3. **Test the API** using the "Test Backend API" button
4. **Monitor** via CloudWatch Dashboard

## Configuration Variables

### **Key Variables**
```hcl
environment = "dev"                           # Environment name
vpc_cidr = "10.0.0.0/16"                     # VPC CIDR block
availability_zones = ["us-east-1a", "us-east-1b"]  # AZ deployment
instance_type = "t2.micro"                   # EC2 instance type
db_instance_class = "db.t3.micro"            # RDS instance type
alarm_email = "your-email@example.com"       # Monitoring alerts
```

## Outputs

After deployment, you'll get:
- `frontend_alb_dns_name` - Application URL
- `backend_alb_dns_name` - Internal API URL
- `rds_endpoint` - Database connection endpoint
- `frontend_asg_name` - Frontend Auto Scaling Group
- `backend_asg_name` - Backend Auto Scaling Group

## Maintenance & Operations

### **Backup Strategy**
- **RDS automated backups** (7-day retention)
- **Multi-AZ failover** capability
- **Auto-scaling storage** up to 100GB
- **Parameter groups** for custom configurations

### **Monitoring**
- **CloudWatch Dashboard**: Real-time metrics
- **Email alerts**: Performance and error notifications
- **Auto Scaling events**: Automatic instance management
- **Health checks**: Continuous application monitoring

### **Updates & Scaling**
- **Horizontal scaling**: Auto Scaling Groups handle demand
- **Vertical scaling**: Instance types can be updated
- **Database scaling**: Storage auto-scales automatically
- **Infrastructure updates**: Terraform state management

## Cost Optimization

- **Auto Scaling**: Pay only for needed capacity
- **t2.micro instances**: Cost-effective for development
- **Multi-AZ**: Balanced availability vs. cost
- **Storage auto-scaling**: Efficient storage usage
- **CloudWatch monitoring**: Optimize based on actual usage

## Security Best Practices

✅ **Network isolation** with private subnets  
✅ **IAM roles** instead of hardcoded credentials  
✅ **Security group layering** with minimal access  
✅ **Multi-AZ deployment** for fault tolerance  
✅ **Encrypted storage** for RDS  
✅ **Monitoring and alerting** for security events  

---

**Architecture Status**: ✅ Production-Ready  
**Total Resources**: 47 AWS resources  
**Deployment Time**: ~10-15 minutes  
**High Availability**: Multi-AZ across 2 zones  
**Auto Scaling**: Frontend + Backend tiers  
**Monitoring**: Full CloudWatch + SNS integration

