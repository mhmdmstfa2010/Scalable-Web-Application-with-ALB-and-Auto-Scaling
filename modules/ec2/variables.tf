variable "ami_id" {
  type = string
  description = "The ID of the AMI to use for the EC2 instance"
}

variable "instance_type" {
  type = string
  description = "The type of the EC2 instance"
}

variable "key_name" {
  type = string
  description = "The name of the key pair to use for the EC2 instance"
  default = "ec2-key-pair"
}

variable "user_data" {
  type = string
  description = "The user data to pass to the EC2 instance"
}

variable "subnet_id" {
  type = list(string)
  description = "The ID of the subnet to launch the EC2 instance in"
}

variable "min_size" {
  type = number
  description = "The minimum number of instances to launch"
}

variable "max_size" {
  type = number
  description = "The maximum number of instances to launch"
}

variable "desired_capacity" {
  type = number
  description = "The desired number of instances to launch"
}

variable "health_check_type" {
  type = string
  description = "The type of health check to perform"
}

variable "health_check_grace_period" {
  type = number
  description = "The grace period for the health check"
}

variable "target_cpu_value" {
  type = number
  description = "Target value for CPU utilization (percentage)"
  default = 70
}

variable "target_group_arn" {
  type = string
  description = "ARN of the ALB target group to attach the ASG to"
}

variable "security_group_ids" {
  type = list(string)
  description = "List of security group IDs for the EC2 instances"
}