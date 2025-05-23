variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod)"
}

variable "asg_name" {
  type        = string
  description = "Name of the Auto Scaling Group to monitor"
}

variable "alb_arn" {
  type        = string
  description = "ARN of the Application Load Balancer"
}

variable "rds_identifier" {
  type        = string
  description = "Identifier of the RDS instance"
}

variable "alarm_email" {
  type        = string
  description = "Email address to receive alarm notifications"
}

variable "cpu_threshold" {
  type        = number
  description = "CPU utilization threshold for alarms"
  default     = 70
}

variable "memory_threshold" {
  type        = number
  description = "Memory utilization threshold for alarms"
  default     = 80
}

variable "response_time_threshold" {
  type        = number
  description = "ALB response time threshold in seconds"
  default     = 5
}

variable "error_rate_threshold" {
  type        = number
  description = "Error rate threshold percentage"
  default     = 5
} 