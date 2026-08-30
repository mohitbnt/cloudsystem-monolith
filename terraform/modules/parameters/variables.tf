# =============================================================================
# Common Module Configuration
# =============================================================================

variable "project_name" {
  type        = string
  description = "Project name used in SSM Parameter Store paths and tags."
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
  description = "AWS region where the SSM parameters are created."

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "The region must be a valid AWS region identifier, for example ap-south-1 or us-east-1."
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to SSM parameters."
}

# =============================================================================
# Runtime Endpoints
# =============================================================================

variable "redis_endpoint" {
  type        = string
  description = "Redis endpoint stored in Parameter Store for EC2 bootstrap."
}

variable "app_bucket" {
  type        = string
  description = "Application uploads S3 bucket name stored in Parameter Store."
}
