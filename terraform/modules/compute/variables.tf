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

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

# Variable for Golden AMI ID
variable "golden_ami_id" {
    type = string
}

variable "vpc_endpoint_sg_id" {
  type        = string
  description = "Security group ID for VPC endpoint"
}

variable "ec2_role_name" {
  type        = string
  description = "IAM role name for EC2 instances"
}

variable "ec2_security_group_id" {
  type        = string
  description = "Security group ID for EC2 instances"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID for ALB"
}

variable "rds_security_group_id" {
  type        = string
  description = "Security group ID for RDS instances"
}

variable "vpc_endpoint_security_group_id" {
  type        = string
  description = "Security group ID for VPC endpoint"
}

variable "app_instance_config" {
  description = "Configuration for the application compute fleet."

  type = object({
    instance_type = string

    root_volume_size      = number
    root_volume_type      = string
    root_volume_encrypted = bool

    desired_capacity = number
    min_size         = number
    max_size         = number

    health_check_grace_period = number
    health_check_type         = string

    protect_scale_in   = bool
    termination_policy = list(string)
  })
}

# TLS Certificate ARN
variable "tls_certificate_arn" {
  description = "The ARN of the TLS certificate"
  type = string
}

# Secrets Manager Secret ARN for DB credentials
variable "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret for DB credentials"
  type = string
}

# Secrets Manager Parameter for S3 bucket
variable "s3_parameter" {
  description = "The name of the Secrets Manager parameter for S3 bucket"
  type = string
}

# Secrets Manager Parameter for Redis endpoint
variable "redis_parameter" {
  description = "The name of the Secrets Manager parameter for Redis endpoint"
  type = string
}

# Database backup bucket name
variable "database_backups_bucket" {
  type = string
}

# Database backup bucket key
variable "database_backups_bucket_key" {
  type = string
}