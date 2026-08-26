data "aws_caller_identity" "current" {}

# Create a S3 bucket for Terraform state with locking enabled
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name
  tags = {
    Name    = var.bucket_name
    Project = var.project
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_config" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create S3 bucket for database backup storage
resource "aws_s3_bucket" "database_backups" {
  bucket           = "database-backups-${data.aws_caller_identity.current.account_id}-${var.region}-an"
  bucket_namespace = "account-regional"
  tags = {
    Name    = "database-backups-${var.project}"
    Project = var.project
  }
}

resource "aws_s3_bucket_versioning" "versioning-database-backups" {
  bucket = aws_s3_bucket.database_backups.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_config-database-backups" {
  bucket = aws_s3_bucket.database_backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access-database-backups" {
  bucket = aws_s3_bucket.database_backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}