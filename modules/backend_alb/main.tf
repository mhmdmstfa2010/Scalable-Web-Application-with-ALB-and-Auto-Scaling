resource "aws_lb" "backend" {
  name               = "${var.environment}-backend-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group]
  subnets            = var.private_subnet_ids

  enable_deletion_protection = var.environment == "production"
  enable_http2              = true

  dynamic "access_logs" {
    for_each = var.access_logs_bucket != null ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = "backend-alb-logs"
      enabled = true
    }
  }

  tags = {
    Name        = "${var.environment}-backend-alb"
    Environment = var.environment
  }
}

# HTTP Listener for API
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backend.arn
  port              = var.api_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

# Backend API Target Group
resource "aws_lb_target_group" "backend" {
  name                 = "${var.environment}-backend-tg"
  port                = var.api_port
  protocol            = "HTTP"
  vpc_id              = var.vpc_id
  target_type         = "instance"
  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher            = "200"
    path               = var.health_check_path
    port               = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.environment}-backend-tg"
    Environment = var.environment
  }
} 