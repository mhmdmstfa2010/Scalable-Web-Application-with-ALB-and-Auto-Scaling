variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidr" {
  description = "List of CIDRs for public subnets, one per AZ"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "List of CIDRs for private subnets, one per AZ"
  type        = list(string)
}