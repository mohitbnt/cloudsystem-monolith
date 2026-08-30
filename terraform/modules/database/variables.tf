# =============================================================================
# Common Module Configuration
# =============================================================================

variable "project_name" {
  type        = string
  description = "Project name used in database resource names and tags."
}

variable "environment" {
  type        = string
  description = "Deployment environment."

  validation {
    condition     = contains(["development", "production"], var.environment)
    error_message = "The environment variable must be exactly 'development' or 'production'."
  }
}

variable "region" {
  type        = string
  description = "AWS region where the RDS instance is deployed."

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "The region must be a valid AWS region identifier, for example ap-south-1 or us-east-1."
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to database resources."
}

# =============================================================================
# Network Configuration
# =============================================================================

variable "vpc_id" {
  type        = string
  description = "VPC ID containing the RDS subnets."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs used by the RDS subnet group."
}

variable "rds_security_group_id" {
  type        = string
  description = "Security group ID attached to the RDS instance."
}

# =============================================================================
# Database Configuration
# =============================================================================

variable "db_instance_config" {
  type = object({
    allocated_storage = number
    family            = string
    engine_version    = string
    instance_class    = string
    db_name           = string
    username          = string
    multi_az          = bool
  })

  description = "Configuration for the MariaDB RDS instance."
}
