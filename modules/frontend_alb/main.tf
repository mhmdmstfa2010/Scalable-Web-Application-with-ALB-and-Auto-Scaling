resource "aws_lb" "frontend" {
  name               = "${var.environment}-frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.environment == "production"
  enable_http2              = true

  dynamic "access_logs" {
    for_each = var.access_logs_bucket != null ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = "frontend-alb-logs"
      enabled = true
    }
  }

  tags = {
    Name        = "${var.environment}-frontend-alb"
    Environment = var.environment
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  count = var.create_https_listener ? 1 : 0

  load_balancer_arn = aws_lb.frontend.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = var.redirect_http_to_https ? "redirect" : "forward"
    
    dynamic "redirect" {
      for_each = var.redirect_http_to_https ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = var.redirect_http_to_https ? [] : [1]
      content {
        target_group {
          arn = aws_lb_target_group.frontend.arn
        }
      }
    }
  }
}

# Frontend Target Group
resource "aws_lb_target_group" "frontend" {
  name                 = "${var.environment}-frontend-tg"
  port                = 80
  protocol            = "HTTP"
  vpc_id              = var.vpc_id
  target_type         = "instance"
  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher            = "200"
    path               = "/"
    port               = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.environment}-frontend-tg"
    Environment = var.environment
  }
}

# API Path-based Routing Rule
resource "aws_lb_listener_rule" "api" {
  count = var.backend_alb_dns_name != null ? 1 : 0

  listener_arn = var.redirect_http_to_https ? aws_lb_listener.https[0].arn : aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = var.backend_target_group_arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
} 