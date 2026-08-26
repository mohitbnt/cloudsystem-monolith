output "app_bucket_arn" {
  value = aws_s3_bucket.app_bucket.arn
}

output "app_bucket" {
  value = aws_s3_bucket.app_bucket.bucket
}