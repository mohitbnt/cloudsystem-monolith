variable "region" {
  type        = string
  description = "The target AWS region for deployment"

  validation {
    # Regex checks for standard regional patterns like "us-east-1" or "ap-southeast-2"
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "The aws_region value must be a valid AWS region identifier (e.g., ap-south-1, us-east-1)."
  }
}

variable "environment" {
  type        = string
  description = "Project environment developmet/production"
  validation {
    condition     = contains(["development", "production"], var.environment)
    error_message = "The environment variable must be exactly 'development' or 'production'."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "common_tags" {
  type = map(string)
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "rds_security_group_id" {
  type        = string
  description = "Security group ID for RDS instances"
}

variable "db_instance_config" {
  description = "Configuration for the database instance."

  type = object({
    family                 = string
    allocated_storage      = number
    engine_version         = string
    instance_class         = string
    db_name                = string
    username               = string
    multi_az               = bool
  })
}