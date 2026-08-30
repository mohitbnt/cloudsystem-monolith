# Create Security Group Rules for EC2 instances

resource "aws_vpc_security_group_ingress_rule" "ec2_instances_ingress" {
    security_group_id = aws_security_group.ec2_instances.id

    for_each    = local.ec2_instances_ingress
    description = "Allow inbound traffic to EC2 instances"
    from_port   = each.value.port
    to_port     = each.value.port
    ip_protocol    = each.value.ip_protocol
    cidr_ipv4      = each.value.use_cidr ? each.value.cidr_block : null
    referenced_security_group_id = each.value.refereced_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "ec2_instances_egress" {
    security_group_id = aws_security_group.ec2_instances.id

    for_each    = local.ec2_instances_egress
    description = "Allow outbound traffic from EC2 instances"
    from_port   = each.value.port
    to_port     = each.value.port
    ip_protocol    = each.value.ip_protocol
    cidr_ipv4      = each.value.use_cidr ? each.value.cidr_block : null
    referenced_security_group_id = each.value.refereced_security_group_id
}

# Create Security Group Rules for ALB
resource "aws_vpc_security_group_ingress_rule" "alb_ingress" {
    security_group_id = aws_security_group.alb.id

    for_each    = local.alb_ingress
    description = "Allow inbound traffic to ALB"
    from_port   = each.value.port
    to_port     = each.value.port
    ip_protocol    = each.value.ip_protocol
    cidr_ipv4      = each.value.use_cidr ? each.value.cidr_block : null
    referenced_security_group_id = each.value.refereced_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "alb_egress" {
    security_group_id = aws_security_group.alb.id

    for_each    = local.alb_egress
    description = "Allow outbound traffic from ALB to EC2 instances only"
    from_port   = each.value.port
    to_port     = each.value.port
    ip_protocol    = each.value.ip_protocol
    cidr_ipv4      = each.value.use_cidr ? each.value.cidr_block : null
    referenced_security_group_id = each.value.refereced_security_group_id
}

# Create Security Group Rules for RDS instances
resource "aws_vpc_security_group_ingress_rule" "rds_ingress" {
    security_group_id = aws_security_group.rds_instances.id

    for_each    = local.rds_ingress
    description = "Allow inbound traffic to RDS"
    from_port   = each.value.port
    to_port     = each.value.port
    ip_protocol    = each.value.ip_protocol
    cidr_ipv4      = each.value.use_cidr ? each.value.cidr_block : null
    referenced_security_group_id = each.value.refereced_security_group_id
}

# Create Security Group Rules for VPC endpoint
resource "aws_vpc_security_group_ingress_rule" "endpoint_sg_ingress" {
    security_group_id = aws_security_group.vpc_endpoint_sg.id

    for_each    = local.endpoint_sg_ingress
    description = "Allow inbound traffic to VPC endpoint"
    from_port   = each.value.port
    to_port     = each.value.port
    ip_protocol    = each.value.ip_protocol
    cidr_ipv4      = each.value.use_cidr ? each.value.cidr_block : null
    referenced_security_group_id = each.value.refereced_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "endpoint_sg_egress" {
    security_group_id = aws_security_group.vpc_endpoint_sg.id

    for_each    = local.endpoint_sg_egress
    description = "Allow outbound traffic from VPC endpoint."
    from_port   = each.value.port
    to_port     = each.value.port
    ip_protocol    = each.value.ip_protocol
    cidr_ipv4      = each.value.use_cidr ? each.value.cidr_block : null
    referenced_security_group_id = each.value.refereced_security_group_id
}

# Add Security Group Rules for Redis Elasticache
resource "aws_vpc_security_group_ingress_rule" "redis_elasticache_ingress" {
    security_group_id = aws_security_group.redis_elasticache_sg.id

    for_each    = local.redis_elasticache_ingress
    description = "Allow inbound traffic to Redis Elasticache"
    from_port   = each.value.port
    to_port     = each.value.port
    ip_protocol    = each.value.ip_protocol
    cidr_ipv4      = each.value.use_cidr ? each.value.cidr_block : null
    referenced_security_group_id = each.value.refereced_security_group_id
}