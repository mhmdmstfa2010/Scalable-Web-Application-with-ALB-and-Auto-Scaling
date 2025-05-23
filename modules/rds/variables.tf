variable "db_name" {
  type = string
  description = "The name of the database"
}

variable "db_username" {
  type = string
  description = "The username for the database"
}

variable "db_password" {    
  type = string
  description = "The password for the database"
  sensitive = true
}

variable "db_instance_class" {
  type = string
  description = "The instance class for the database"
  default = "db.t3.micro"
}

variable "db_engine" {  
  type = string
  description = "The engine for the database"
  default = "mysql"
}

variable "db_engine_version" {
  type = string
  description = "The engine version for the database"
  default = "8.0"
}

variable "db_allocated_storage" {       
  type = number
  description = "The allocated storage for the database in GB"
  default = 20
}

variable "db_max_allocated_storage" {
  type = number
  description = "The max allocated storage for the database in GB"
  default = 100
}

variable "db_storage_type" {
  type = string
  description = "The storage type for the database"
  default = "gp2"
}

variable "db_backup_retention_period" {
  type = number
  description = "The backup retention period for the database in days"
  default = 7
}

variable "multi_az" {
  type = bool
  description = "Whether to enable Multi-AZ deployment"
  default = true
}

variable "skip_final_snapshot" {
  type = bool
  description = "Whether to skip final snapshot when destroying the database"
  default = false
}

variable "backup_window" {
  type = string
  description = "The daily time range during which automated backups are created"
  default = "03:00-04:00"
}

variable "maintenance_window" {
  type = string
  description = "The window to perform maintenance in"
  default = "Mon:04:00-Mon:05:00"
}

variable "storage_encrypted" {
  type = bool
  description = "Whether to enable storage encryption"
  default = true
}

variable "port" {
  type = number
  description = "The port on which the DB accepts connections"
  default = 3306
}

variable "deletion_protection" {
  type = bool
  description = "If the DB instance should have deletion protection enabled"
  default = true
}

variable "parameter_group_family" {
  type = string
  description = "The family of the DB parameter group"
  default = "mysql8.0"
}

variable "parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "A list of DB parameters to apply"
  default = []
}

variable "tags" {
  type = map(string)
  description = "A map of tags to add to all resources"
  default = {}
}

variable "vpc_private_subnet_ids" {
  type = list(string)
  description = "List of VPC private subnet IDs for the RDS subnet group"
}

variable "security_group_ids" {
  type = list(string)
  description = "List of security group IDs for the RDS instance"
}

