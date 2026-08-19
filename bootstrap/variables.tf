# AWS region for the bucket
variable "region" {
  type        = string
  description = "AWS region"
  default     = "ap-south-1"
}

# Project name
variable "project" {
  type        = string
  description = "Project name"
  default     = "cloud-medusa-monolith"
}

# Bucket name
variable "bucket_name" {
  type        = string
  description = "Name of the bucket"
  default     = "cloud-medusa-monolith-terraform-state"
}

# Variabled for OIDC configuration

variable "github_repo_path" {
  type        = string
  description = "Path to the Github repository"
}

variable "github_branch" {
  type        = string
  description = "Branch name"
  default     = "refs/heads/main"
}