output "alb_dns_name" {
  description = "DNS name of the frontend ALB"
  value       = aws_lb.frontend.dns_name
}

output "alb_arn" {
  description = "ARN of the frontend ALB"
  value       = aws_lb.frontend.arn
}

output "target_group_arn" {
  description = "ARN of the frontend target group"
  value       = aws_lb_target_group.frontend.arn
}

output "target_group_name" {
  description = "Name of the frontend target group"
  value       = aws_lb_target_group.frontend.name
} 