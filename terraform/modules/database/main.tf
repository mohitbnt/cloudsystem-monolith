# Get the random password for the database
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Create a database subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db-subnet-group"
    }
  )
}

# Create a parameter group for the PostgreSQL database
resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "${var.project_name}-${var.environment}-db-parameter-group"
  family      = var.db_instance_config.family
  description = "Parameter group for PostgreSQL database"

  parameter {
    name  = "max_connections"
    value = "100"
  }

  parameter {
    name  = "shared_buffers"
    value = "256MB"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db-parameter-group"
    }
  )
}

# Create PostgreSQL database instance
resource "aws_db_instance" "db_instance" {
  identifier             = "${var.project_name}-${var.environment}-db-instance"
  allocated_storage      = var.db_instance_config.allocated_storage
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = var.db_instance_config.engine_version
  instance_class         = var.db_instance_config.instance_class
  db_name                = var.db_instance_config.db_name
  username               = var.db_instance_config.username
  password               = random_password.db_password.result
  port                   = 5432
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.rds_security_group_id]
  skip_final_snapshot    = true
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name
  multi_az               = var.db_instance_config.multi_az
  backup_retention_period = 0
  deletion_protection     = false
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db-instance"
    }
  )
}

# Create Secrets Manager secret for PostgreSQL connection string
resource "aws_secretsmanager_secret" "db_secret" {
  name        = "${var.project_name}-${var.environment}/postgres/credentials"
  description = "PostgreSQL database credentials"
}

# Create the Secret version holding the data
resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = "postgresql://${var.db_instance_config.username}:${random_password.db_password.result}@${aws_db_instance.db_instance.endpoint}/${var.db_instance_config.db_name}"
}