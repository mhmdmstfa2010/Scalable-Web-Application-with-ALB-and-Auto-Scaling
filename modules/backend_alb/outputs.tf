output "alb_dns_name" {
  description = "DNS name of the backend ALB"
  value       = aws_lb.backend.dns_name
}

output "alb_arn" {
  description = "ARN of the backend ALB"
  value       = aws_lb.backend.arn
}

output "target_group_arn" {
  description = "ARN of the backend target group"
  value       = aws_lb_target_group.backend.arn
}

output "target_group_name" {
  description = "Name of the backend target group"
  value       = aws_lb_target_group.backend.name
} 