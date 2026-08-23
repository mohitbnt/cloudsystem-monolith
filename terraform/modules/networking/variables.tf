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

variable "vpc_cidr" {
  type = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The vpc cidr must be valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Explicit list of CIDR blocks for the public subnets"
  validation {
    condition     = alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All elements in the public_subnet_cidrs list must be valid IPv4 CIDR blocks."
  }

}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Explicit list of CIDR blocks for the private subnets"
  validation {
    # Loops through the list to ensure every single entry is a valid CIDR
    condition     = alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All elements in the public_subnet_cidrs list must be valid IPv4 CIDR blocks."
  }
}

variable "vpc_endpoint_sg_id" {
  type        = string
  description = "Security group ID for VPC endpoint"
}