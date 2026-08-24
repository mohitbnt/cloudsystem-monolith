# Create a parameter store for Redis URL
resource "aws_ssm_parameter" "redis_url" {
  name  = "/${var.project_name}/${var.environment}/redis_url"
  type  = "String"
  value = var.redis_url

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-redis-url"
    }
  )
}
