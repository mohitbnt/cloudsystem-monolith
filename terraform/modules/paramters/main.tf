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

# Create a parameter store for Golden AMI ID
resource "aws_ssm_parameter" "golden_ami_id" {
  name  = "/${var.project_name}/${var.environment}/golden_ami_id"
  type  = "String"
  value = var.golden_ami_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-golden-ami-id"
    }
  )
}