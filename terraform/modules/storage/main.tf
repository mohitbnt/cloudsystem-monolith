# Create S3 bucket
resource "aws_s3_bucket" "store_bucket" {
  bucket        = var.store_bucket_name
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-medusa-storage"
    }
  )
}

# Allow public access to the bucket
resource "aws_s3_bucket_public_access_block" "bucket-public_access" {
  bucket = aws_s3_bucket.store_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# policy using data block for bucket policy
data "aws_iam_policy_document" "bucket_public_read" {
  statement {
    sid       = "AllowPublicRead"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.store_bucket.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  } 
}

# Create a bucket policy allowing public access to the bucket
resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.store_bucket.id
  policy = data.aws_iam_policy_document.bucket_public_read.json
}

#  Configure CORS Rules
resource "aws_s3_bucket_cors_configuration" "bucket-cors" {
  bucket = aws_s3_bucket.store_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}