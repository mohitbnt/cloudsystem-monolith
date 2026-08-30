# =============================================================================
# Common Project Configuration
# =============================================================================

variable "project_name" {
  type        = string
  description = "Short project name used as the prefix for AWS resource names and tags."
}

variable "environment" {
  type        = string
  description = "Deployment environment for the application."

  validation {
    condition     = contains(["development", "production"], var.environment)
    error_message = "The environment variable must be exactly 'development' or 'production'."
  }
}

variable "region" {
  type        = string
  description = "AWS region where the infrastructure is deployed."

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "The region must be a valid AWS region identifier, for example ap-south-1 or us-east-1."
  }
}

variable "domain_name" {
  type        = string
  description = "Primary DNS name used by the WordPress application."
}

# =============================================================================
# External Services
# =============================================================================

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token used by Terraform to manage DNS records."
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare Zone ID containing the application's DNS records."
}

# =============================================================================
# Application / Compute
# =============================================================================

variable "golden_ami_id" {
  type        = string
  description = "AMI ID of the WordPress Golden AMI used by the EC2 Auto Scaling Group."
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

  description = "Configuration for the WordPress EC2 Auto Scaling Group and instance storage."
}

# =============================================================================
# Database
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

  description = "Configuration for the Amazon RDS MariaDB instance."
}

variable "db_backup_key_file" {
  type        = string
  description = "S3 object key for the WordPress database dump stored in the private artifacts bucket."
}

# =============================================================================
# Cache
# =============================================================================

variable "cache_config" {
  type = object({
    engine_version             = string
    node_type                  = string
    auotmatic_failover_enabled = bool
    multi_az_enabled           = bool
  })

  description = "Configuration for the Amazon ElastiCache for Redis deployment."
}

# =============================================================================
# Artifact Storage
# =============================================================================

variable "artifacts_bucket" {
  type        = string
  description = "Private S3 bucket containing AMI artifacts and database dumps."
}

variable "artifacts_bucket_arn" {
  type        = string
  description = "ARN of the private S3 artifacts bucket."
}

# =============================================================================
# Network Configuration
# =============================================================================

variable "vpc_cidr" {
  type        = string
  description = "IPv4 CIDR block for the VPC."

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the public subnets."

  validation {
    condition     = alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All public_subnet_cidrs values must be valid IPv4 CIDR blocks."
  }
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for the private subnets."

  validation {
    condition     = alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All private_subnet_cidrs values must be valid IPv4 CIDR blocks."
  }
}

variable "vpc_endpoint_sg_id" {
  type        = string
  description = "Security group ID used by the VPC interface endpoints."
}
