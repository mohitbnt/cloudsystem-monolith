# AWS Region
variable "region" {
  type        = string
  description = "The target AWS region for deployment"

  validation {
    # Regex checks for standard regional patterns like "us-east-1" or "ap-southeast-2"
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "The aws_region value must be a valid AWS region identifier (e.g., ap-south-1, us-east-1)."
  }
}

# Project Environment
variable "environment" {
  type        = string
  description = "Project environment developmet/production"
  validation {
    condition     = contains(["development", "production"], var.environment)
    error_message = "The environment variable must be exactly 'development' or 'production'."
  }
}
# Project Name
variable "project_name" {
  description = "Name of the project"
  type        = string
}

# Cloudflare API Token
variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
}

# Cloudflare Zone ID
variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

# Domain Name for the application
variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

#  Variable for Golden AMI ID
variable "golden_ami_id" {
  type = string
}

# VPC and Subnets
variable "vpc_cidr" {
  type = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The vpc cidr must be valid IPv4 CIDR block."
  }
}

# Public Subnet CIDRs
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Explicit list of CIDR blocks for the public subnets"
  validation {
    condition     = alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All elements in the public_subnet_cidrs list must be valid IPv4 CIDR blocks."
  }

}

# Private Subnet CIDRs
variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Explicit list of CIDR blocks for the private subnets"
  validation {
    # Loops through the list to ensure every single entry is a valid CIDR
    condition     = alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All elements in the public_subnet_cidrs list must be valid IPv4 CIDR blocks."
  }
}

# Application Instance Configuration
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

# Database Instance Configuration
variable "db_instance_config" {
  description = "Configuration for the application compute fleet."

  type = object({
    family            = string
    allocated_storage = number
    engine_version    = string
    instance_class    = string
    db_name           = string
    username          = string
    multi_az          = bool
  })
}

# Cache Configuration
variable "cache_config" {
  description = "Configuration for the application compute fleet."

  type = object({
    engine_version             = string
    node_type                  = string
    auotmatic_failover_enabled = bool
    multi_az_enabled           = bool
  })
}

# Artifacts bucket name
variable "artifacts_bucket" {
  type = string
}

# Artifacts bucket arn
variable "artifacts_bucket_arn" {
  type = string
}

# Database backup bucket key
variable "db_backup_key_file" {
  type = string
}