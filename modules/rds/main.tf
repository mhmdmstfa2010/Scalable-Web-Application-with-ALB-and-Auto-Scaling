# Create DB subnet group
resource "aws_db_subnet_group" "main" {
  name        = "${var.db_name}-subnet-group"
  description = "Subnet group for ${var.db_name} RDS instance"
  subnet_ids  = var.vpc_private_subnet_ids
}

# Create DB parameter group
resource "aws_db_parameter_group" "main" {
  name        = "${var.db_name}-parameter-group"
  family      = var.parameter_group_family
  description = "Parameter group for ${var.db_name} RDS instance"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = var.tags
}

# Create RDS instance
resource "aws_db_instance" "main" {
  identifier = var.db_name
  
  # Engine settings
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  # Storage settings
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type         = var.db_storage_type
  storage_encrypted    = var.storage_encrypted

  # Network settings
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.security_group_ids
  port                   = var.port
  multi_az              = var.multi_az

  # Authentication
  username = var.db_username
  password = var.db_password

  # Backup and maintenance
  backup_retention_period = var.db_backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  skip_final_snapshot    = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.db_name}-final-snapshot"

  # Additional settings
  parameter_group_name = aws_db_parameter_group.main.name
  deletion_protection  = var.deletion_protection

  # Allow minor version upgrades and auto patching
  auto_minor_version_upgrade = true
  apply_immediately         = false  # Be careful with changes

  tags = var.tags
}

