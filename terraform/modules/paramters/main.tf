# Create a parameter store for Redis URL
resource "aws_ssm_parameter" "redis_endpoint" {
  name  = "/${var.project_name}/${var.environment}/redis_endpoint"
  type  = "String"
  value = var.redis_endpoint

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-redis-endpoint"
    }
  )
}

resource "aws_ssm_parameter" "app_bucket" {
  name  = "/${var.project_name}/${var.environment}/app_bucket"
  type  = "String"
  value = var.app_bucket

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-app-bucket"
    }
  )
}