variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "alb_security_group" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "access_logs_bucket" {
  description = "S3 bucket name for ALB access logs"
  type        = string
  default     = null
}

variable "create_https_listener" {
  description = "Whether to create HTTPS listener"
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ARN of SSL certificate for HTTPS listener"
  type        = string
  default     = null
}

variable "redirect_http_to_https" {
  description = "Whether to redirect HTTP traffic to HTTPS"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "backend_alb_dns_name" {
  description = "DNS name of the backend ALB for API routing"
  type        = string
  default     = null
}

variable "backend_target_group_arn" {
  description = "ARN of the backend target group for API routing"
  type        = string
  default     = null
} 