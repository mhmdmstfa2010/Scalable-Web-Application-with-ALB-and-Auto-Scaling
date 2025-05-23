output "asg_id" {
  value       = aws_autoscaling_group.ec2_autoscaling_group.id
  description = "ID of the Auto Scaling Group"
}

output "asg_name" {
  value       = aws_autoscaling_group.ec2_autoscaling_group.name
  description = "Name of the Auto Scaling Group"
}

output "asg_arn" {
  value       = aws_autoscaling_group.ec2_autoscaling_group.arn
  description = "ARN of the Auto Scaling Group"
}

output "launch_template_id" {
  value       = aws_launch_template.ec2_launch_template.id
  description = "ID of the Launch Template"
}

output "launch_template_arn" {
  value       = aws_launch_template.ec2_launch_template.arn
  description = "ARN of the Launch Template"
} 