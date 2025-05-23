# Scalable Web Application Infrastructure

This project implements a highly available and scalable web application infrastructure on AWS using Terraform. The architecture follows AWS best practices for security, scalability, and high availability.

## Architecture Diagram

![AWS Infrastructure Diagram](Scalable%20Web%20Application%20with%20ALB%20and%20Auto%20Scaling.png)

## Infrastructure Components

### 1. Network Layer (VPC Module)
- VPC with CIDR block: 10.0.0.0/16
- Public Subnets: 10.0.1.0/24, 10.0.2.0/24
- Private Subnets: 10.0.101.0/24, 10.0.102.0/24
- NAT Gateways for private subnet internet access
- Internet Gateway for public subnets

### 2. Load Balancer (ALB Module)
- Application Load Balancer in public subnets
- HTTP (80) listener with optional HTTPS (443)
- Health checks configured
- Access logs enabled
- Security group allowing inbound HTTP/HTTPS

### 3. Compute Layer (EC2/ASG Module)
- Auto Scaling Group across AZs
- Launch Template 
- Instance Type: t2.micro
- Apache web server installed via user data
- Scaling policies based on CPU utilization
- Security group allowing traffic from ALB

### 4. Database Layer (RDS Module)
- MySQL 8.0 database
- Multi-AZ deployment
- Instance Class: db.t3.micro
- Automated backups (7-day retention)
- Security group allowing traffic from EC2

### 5. Monitoring (Monitoring Module)
- CloudWatch Dashboard
- CPU, Memory, and Request metrics
- Custom alarms for:
  - High CPU utilization
  - High response time
  - Error rates
  - Database performance
- SNS notifications for alerts

## Security Features

1. **Network Security**
   - Private subnets for application and database
   - NAT Gateways for outbound internet access
   - Security group layering

2. **Access Control**
   - ALB in public subnets only
   - EC2 instances in private subnets
   - RDS in private subnets
   - Key pair for EC2 access

3. **Monitoring & Logging**
   - ALB access logs
   - CloudWatch metrics
   - SNS notifications

## High Availability

- Multi-AZ deployment
- Auto Scaling across AZs
- RDS Multi-AZ
- Load balancer for traffic distribution

## Getting Started

1. **Prerequisites**
   ```bash
   - AWS CLI configured
   - Terraform installed
   - AWS account with appropriate permissions
   ```

2. **Configuration**
   ```bash
   # Initialize Terraform
   terraform init

   # Review the plan
   terraform plan

   # Apply the infrastructure
   terraform apply
   ```

3. **Post-Deployment**
   - Confirm SNS subscription for alerts
   - Access the application via ALB DNS name
   - Monitor the CloudWatch dashboard

## Variables

Key variables that can be customized:
- `environment`: Environment name (dev/prod)
- `vpc_cidr`: VPC CIDR block
- `instance_type`: EC2 instance type
- `db_instance_class`: RDS instance class
- `alarm_email`: Email for monitoring alerts

## Maintenance

1. **Backup Strategy**
   - RDS automated backups
   - Snapshot before major changes
   - Regular backup testing

2. **Monitoring**
   - Review CloudWatch metrics
   - Check ALB access logs
   - Monitor scaling events

3. **Updates**
   - Regular security patches
   - Database maintenance
   - Infrastructure updates

## Cost Optimization

- Auto Scaling based on demand
- t2.micro instances for development
- Multi-AZ only where necessary
- CloudWatch metrics for resource optimization

