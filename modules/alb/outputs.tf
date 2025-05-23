output "alb_target_group_id" {
  value = aws_lb_target_group.alb_target_group.id
  description = "ID of the ALB target group"
}

output "alb_target_group_name" {
  value = aws_lb_target_group.alb_target_group.name
  description = "Name of the ALB target group"
}

output "alb_target_group_port" {
  value = aws_lb_target_group.alb_target_group.port
  description = "Port of the ALB target group"
}

output "alb_target_group_protocol" {
  value = aws_lb_target_group.alb_target_group.protocol
  description = "Protocol of the ALB target group"
}

output "alb_target_group_target_type" {
  value = aws_lb_target_group.alb_target_group.target_type
  description = "Target type of the ALB target group"
}

output "alb_target_group_vpc_id" {
  value = aws_lb_target_group.alb_target_group.vpc_id
  description = "VPC ID of the ALB target group"
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
  description = "DNS name of the ALB"
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.alb.zone_id
}

output "alb_arn" {
  value = aws_lb.alb.arn
  description = "ARN of the ALB"
} 