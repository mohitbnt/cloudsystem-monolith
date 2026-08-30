# =============================================================================
# Common Module Configuration
# =============================================================================

variable "project_name" {
  type        = string
  description = "Project name used in compute resource names and tags."
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
  description = "AWS region where the compute resources are deployed."

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "The region must be a valid AWS region identifier, for example ap-south-1 or us-east-1."
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to compute resources."
}

# =============================================================================
# Network Configuration
# =============================================================================

variable "vpc_id" {
  type        = string
  description = "VPC ID containing the compute resources."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs used by the Application Load Balancer."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs used by the EC2 Auto Scaling Group."
}

# =============================================================================
# Security / IAM
# =============================================================================

variable "ec2_role_name" {
  type        = string
  description = "IAM role name attached to EC2 instances."
}

variable "ec2_security_group_id" {
  type        = string
  description = "Security group ID attached to EC2 instances."
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID attached to the Application Load Balancer."
}

variable "rds_security_group_id" {
  type        = string
  description = "RDS security group ID used by compute dependencies."
}

variable "vpc_endpoint_sg_id" {
  type        = string
  description = "Security group ID for VPC interface endpoints."
}

variable "vpc_endpoint_security_group_id" {
  type        = string
  description = "VPC endpoint security group ID retained for compute module compatibility."
}

# =============================================================================
# Application Configuration
# =============================================================================

variable "golden_ami_id" {
  type        = string
  description = "AMI ID of the WordPress Golden AMI."
}

variable "app_instance_config" {
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

  description = "EC2 Auto Scaling Group and root volume configuration."
}

variable "tls_certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate used by the HTTPS ALB listener."
}

# =============================================================================
# Runtime Configuration
# =============================================================================

variable "db_secret_arn" {
  type        = string
  description = "ARN of the Secrets Manager secret containing MariaDB credentials."
}

variable "s3_parameter" {
  type        = string
  description = "SSM Parameter Store name containing the application S3 bucket name."
}

variable "redis_parameter" {
  type        = string
  description = "SSM Parameter Store name containing the Redis endpoint."
}

variable "artifacts_bucket" {
  type        = string
  description = "Private S3 artifacts bucket containing the database dump."
}

variable "db_backup_key_file" {
  type        = string
  description = "S3 object key of the database dump consumed by EC2 user-data."
}
