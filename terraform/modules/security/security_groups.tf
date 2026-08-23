# Create Securty Group for EC2 instances
resource "aws_security_group" "ec2_instances" {
    name        = "${var.project_name}-${var.environment}-ec2-sg"
    description = "Security group for Auto Scaling Group instances"
    vpc_id      = var.vpc_id

    tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-ec2-sg"
    })
}

# Create Securty Group for ALB
resource "aws_security_group" "alb" {
    name        = "${var.project_name}-${var.environment}-alb-sg"
    description = "Security group for ALB"
    vpc_id      = var.vpc_id

    tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-alb-sg"
    })
}

# Create Securty Group for RDS instances
resource "aws_security_group" "rds_instances" {
    name        = "${var.project_name}-${var.environment}-rds-sg"
    description = "Allow inbound traffic to RDS instances"
    vpc_id      = var.vpc_id

    tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-rds-sg"
    })
}

# Create Securty Group for VPC endpoint
resource "aws_security_group" "vpc_endpoint_sg" {
    name        = "${var.project_name}-${var.environment}-vpc-endpoint-sg"
    description = "Security group for VPC endpoint"
    vpc_id      = var.vpc_id

    tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-vpc-endpoint-sg"
    })
}

# Create Security Group for Redis Elasticache
resource "aws_security_group" "redis_elasticache_sg" {
    name        = "${var.project_name}-${var.environment}-redis-elasticache-sg"
    description = "Security group for Redis Elasticache"
    vpc_id      = var.vpc_id

    tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-redis-elasticache-sg"
    })
}