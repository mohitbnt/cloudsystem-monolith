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

# Cloudflare Zone ID
variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type = string
}

# Domain Name for the application
variable "domain_name" {
  description = "Domain name for the application"
  type = string
}

# ALB DNS Name
variable "alb_dns_name" {
    description = "The DNS name of the ALB"
    type = string
}