variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod)"
  default     = "dev"
}

variable "alb_port" {
  type        = number
  description = "Port for ALB listener"
  default     = 80
}

variable "app_port" {
  type        = number
  description = "Port for the application on EC2"
  default     = 80
}

variable "db_port" {
  type        = number
  description = "Port for the database"
  default     = 3306  # MySQL default
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access ALB"
  default     = ["0.0.0.0/0"]  # Be more restrictive in production
}