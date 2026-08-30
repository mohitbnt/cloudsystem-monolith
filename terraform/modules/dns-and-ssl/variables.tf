# =============================================================================
# Common Module Configuration
# =============================================================================

variable "project_name" {
  type        = string
  description = "Project name used in DNS and certificate resource names."
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
  description = "AWS region where the ACM certificate is created."

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "The region must be a valid AWS region identifier, for example ap-south-1 or us-east-1."
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to DNS and certificate resources."
}

# =============================================================================
# DNS / TLS Configuration
# =============================================================================

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare Zone ID where DNS validation and application records are created."
}

variable "domain_name" {
  type        = string
  description = "Primary application domain used for the ACM certificate and DNS records."
}

variable "alb_dns_name" {
  type        = string
  description = "DNS name of the Application Load Balancer targeted by the application DNS record."
}
