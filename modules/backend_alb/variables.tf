variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "alb_security_group" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the ALB"
  type        = list(string)
}

variable "access_logs_bucket" {
  description = "S3 bucket name for ALB access logs"
  type        = string
  default     = null
}

variable "api_port" {
  description = "Port for the API service"
  type        = number
  default     = 8080
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "health_check_path" {
  description = "Path for health check"
  type        = string
  default     = "/api/health"
} 