# Publis VPC Endpoint Security Group ID
output "vpc_endpoint_sg_id" {
    value = aws_security_group.vpc_endpoint_sg.id
}

# Publish EC2 Role Name
output "ec2_role_name" {
  value = aws_iam_role.ec2_role.name
}

# Publish EC2 Security Group ID
output "ec2_security_group_id" {
  value = aws_security_group.ec2_instances.id
}

# Publish ALB Security Group ID
output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

# Publish RDS Security Group ID
output "rds_security_group_id" {
  value = aws_security_group.rds_instances.id
}

# Publish VPC Endpoint Security Group ID
output "vpc_endpoint_security_group_id" {
  value = aws_security_group.vpc_endpoint_sg.id
} 

# Publish Redis Elasticache Security Group ID
output "redis_elasticache_sg_id" {
  value = aws_security_group.redis_elasticache_sg.id
}