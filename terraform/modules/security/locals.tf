locals {

# Security Group Rules
    ec2_instances_ingress = {
        http = {
            description = "Allow inbound traffic to EC2 instances"
            port   = 80
            ip_protocol = "tcp"
            use_cidr   = false
            cidr_block = "null"
            refereced_security_group_id = aws_security_group.alb.id
        }
    }    
    ec2_instances_egress = {
        all_traffic = {
            description = "Allow outbound traffic from EC2 instances"
            port   = null
            ip_protocol = "-1"
            cidr_block = "0.0.0.0/0"
            use_cidr   = true
            refereced_security_group_id = null
        }
    }
    alb_ingress = {
        http = {
            description = "Allow inbound traffic to ALB"
            port   = 80
            ip_protocol = "tcp"
            use_cidr   = true
            cidr_block = "0.0.0.0/0"
            refereced_security_group_id = null
        }
        https = {
            description = "Allow inbound traffic to ALB"
            port   = 443
            ip_protocol = "tcp"
            use_cidr   = true
            cidr_block = "0.0.0.0/0"
            refereced_security_group_id = null
        }
    }
    alb_egress = {
        http = {
            description = "Allow outbound traffic from ALB to EC2 instances only"
            port   = 80
            ip_protocol = "tcp"
            cidr_block = null
            use_cidr   = false
            refereced_security_group_id = aws_security_group.ec2_instances.id
        }
    }
    postgres_ingress = {
        psql-port = {
            description = "Allow inbound traffic to Postgres"
            port   = 5432
            ip_protocol = "tcp"
            use_cidr   = false
            cidr_block = "null"
            refereced_security_group_id = aws_security_group.ec2_instances.id
        }
    }
    endpoint_sg_ingress = {
        https = {
            description = "Allow inbound traffic to VPC endpoint"
            port   = 443
            ip_protocol = "tcp"
            use_cidr   = false
            cidr_block = null
            refereced_security_group_id = aws_security_group.ec2_instances.id
        }
    }
    endpoint_sg_egress = {
        all_traffic = {
            description = "Allow outbound traffic from VPC endpoint."
            port   = null
            ip_protocol = "-1"
            cidr_block = "0.0.0.0/0"
            use_cidr   = true
            refereced_security_group_id = null
        }
    }
    redis_elasticache_ingress = {
        redis-port = {
            description = "Allow inbound traffic to Redis Elasticache"
            port   = 6379
            ip_protocol = "tcp"
            use_cidr   = false
            cidr_block = "null"
            refereced_security_group_id = aws_security_group.ec2_instances.id
        }
    }
}