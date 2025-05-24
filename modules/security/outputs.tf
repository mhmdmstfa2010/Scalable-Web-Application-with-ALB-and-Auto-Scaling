output "frontend_alb_security_group_id" {
  description = "ID of the frontend ALB security group"
  value       = aws_security_group.frontend_alb.id
}

output "frontend_ec2_security_group_id" {
  description = "ID of the frontend EC2 security group"
  value       = aws_security_group.frontend_ec2.id
}

output "backend_alb_security_group_id" {
  description = "ID of the backend ALB security group"
  value       = aws_security_group.backend_alb.id
}

output "backend_ec2_security_group_id" {
  description = "ID of the backend EC2 security group"
  value       = aws_security_group.backend_ec2.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
} 