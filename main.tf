module "vpc" {
  source = "./modules/vpc"  

  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  public_subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24" ]
  private_subnet_cidr= ["10.0.101.0/24", "10.0.102.0/24" ]

}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

module "security" {
  source = "./modules/security"
  
  vpc_id = module.vpc.vpc_id
  environment = "dev"
  alb_port = 80
  app_port = 80
  db_port = 3306
}

module "alb" {
  source = "./modules/alb"
  
  alb_name = "alb"
  vpc_id = module.vpc.vpc_id
  alb_subnets = module.vpc.public_subnet_ids
  environment = "dev"
  access_logs_bucket = "my-alb-logs"
  target_group_name = "my-target-group"
  target_group_port = 80
  target_group_protocol = "HTTP"
  health_check_path = "/"
  target_type = "instance"
  
  # Security Group Assignment
  alb_security_group = module.security.alb_security_group_id

  depends_on = [module.security]
}

output "alb_target_group_id" {
  value = module.alb.alb_target_group_id
}

output "alb_target_group_name" {
  value = module.alb.alb_target_group_name
}

output "alb_target_group_port" {
  value = module.alb.alb_target_group_port
}

output "alb_target_group_protocol" {
  value = module.alb.alb_target_group_protocol
}

output "alb_target_group_target_type" {
  value = module.alb.alb_target_group_target_type
}

output "alb_target_group_vpc_id" {
  value = module.alb.alb_target_group_vpc_id
}

module "ec2" {
  source = "./modules/ec2"
  
  # Instance Configuration
  ami_id = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  key_name = "ALB_key"
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF
  )

  # ASG Configuration
  min_size = 1
  max_size = 3
  desired_capacity = 2
  health_check_type = "ELB"
  health_check_grace_period = 300
  
  # Networking
  subnet_id = module.vpc.private_subnet_ids
  target_group_arn = module.alb.alb_target_group_id

  # Security Group Assignment
  security_group_ids = [module.security.ec2_security_group_id]

  # Scaling Policy
  target_cpu_value = 70

  depends_on = [module.security, module.alb]
}

module "rds" {
  source = "./modules/rds"
  
  # Basic Settings
  db_name = "myappdb"
  db_username = "admin"
  db_password = "YourSecurePassword123!"  # Use SSM Parameter Store in production
  db_instance_class = "db.t3.micro"
  
  # Engine
  db_engine = "mysql"
  db_engine_version = "8.0"
  
  # Storage
  db_allocated_storage = 20
  db_max_allocated_storage = 100
  db_storage_type = "gp2"
  
  # Network
  vpc_private_subnet_ids = module.vpc.private_subnet_ids
  
  # Security Group Assignment
  security_group_ids = [module.security.rds_security_group_id]
  
  # Backup
  db_backup_retention_period = 7
  multi_az = false  # Set to true for production
  
  # Tags
  tags = {
    Environment = "dev"
    Project = "my-app"
  }

  depends_on = [module.security, module.ec2]
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "rds_port" {
  value = module.rds.db_instance_port
}

module "monitoring" {
  source = "./modules/monitoring"

  environment     = "dev"
  asg_name        = module.ec2.asg_name
  alb_arn         = module.alb.alb_arn
  rds_identifier  = module.rds.db_instance_id
  alarm_email     = "your-email@example.com"  # Replace with your email
  
  # Optional: Override default thresholds
  cpu_threshold           = 70
  memory_threshold       = 80
  response_time_threshold = 5
  error_rate_threshold   = 5

  depends_on = [module.ec2, module.alb, module.rds]
}

# Add monitoring outputs
output "monitoring_dashboard_name" {
  value = module.monitoring.dashboard_name
}

output "monitoring_sns_topic_arn" {
  value = module.monitoring.sns_topic_arn
}

output "monitoring_alarm_names" {
  value = module.monitoring.alarm_names
}   