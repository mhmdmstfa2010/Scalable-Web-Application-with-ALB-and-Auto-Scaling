# Frontend ALB Security Group
resource "aws_security_group" "frontend_alb" {
  name        = "${var.environment}-frontend-alb-sg"
  description = "Security group for frontend ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-frontend-alb-sg"
  }
}

# Frontend EC2 Security Group
resource "aws_security_group" "frontend_ec2" {
  name        = "${var.environment}-frontend-ec2-sg"
  description = "Security group for frontend EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from Frontend ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-frontend-ec2-sg"
  }
}

# Backend ALB Security Group
resource "aws_security_group" "backend_alb" {
  name        = "${var.environment}-backend-alb-sg"
  description = "Security group for backend ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "API traffic from frontend EC2"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-backend-alb-sg"
  }
}

# Backend EC2 Security Group
resource "aws_security_group" "backend_ec2" {
  name        = "${var.environment}-backend-ec2-sg"
  description = "Security group for backend EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Traffic from Backend ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-backend-ec2-sg"
  }
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Database access from Backend EC2"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_ec2.id]
  }

  tags = {
    Name = "${var.environment}-rds-sg"
  }
}
