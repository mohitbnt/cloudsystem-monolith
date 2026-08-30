# =============================================================================
# Common Module Configuration
# =============================================================================

variable "project_name" {
  type        = string
  description = "Project name used in resource names and tags."
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
  description = "AWS region where security resources are deployed."

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "The region must be a valid AWS region identifier, for example ap-south-1 or us-east-1."
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to security resources."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the security groups are created."
}

# =============================================================================
# S3 Access
# =============================================================================

variable "app_bucket_arn" {
  type        = string
  description = "ARN of the WordPress application uploads S3 bucket."
}

variable "artifacts_bucket_arn" {
  type        = string
  description = "ARN of the private artifacts S3 bucket."
}
