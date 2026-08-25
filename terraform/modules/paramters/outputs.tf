# Publish S3 Parameter
output "s3_parameter" {
  description = "S3 Parameter"
  value = aws_ssm_parameter.app_bucket.name
}

# Publish Redis Parameter
output "redis_parameter" {
  description = "Redis Parameter"
  value = aws_ssm_parameter.redis_endpoint.name
}