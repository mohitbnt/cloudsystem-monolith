terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.23.0"
    }
  }
  backend "s3" {
    bucket       = "repo-1338375073-tfstate"
    key          = "medusa-monolith/global/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}