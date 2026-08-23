
# Create Subnet Group for Redis Elasticache
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${var.project_name}-${var.environment}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-redis-subnet-group"
    }
  )
}

# Create parameter group for Redis Elasticache
resource "aws_elasticache_parameter_group" "redis_parameter_group" {
  name        = "${var.project_name}-${var.environment}-redis-parameter-group"
  family      = "redis7"
  description = "Parameter group for Redis Elasticache"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-redis-parameter-group"
    }
  )
}

# Create Redis Elasticache Replication Group (Cluster)
resource "aws_elasticache_replication_group" "redis_cluster" {
  replication_group_id = "${var.project_name}-${var.environment}-redis-cluster"
  description          = "Redis Elasticache Cluster"
  
  engine             = "redis"
  engine_version     = var.cache_config.engine_version
  node_type          = var.cache_config.node_type
  port               = 6379
  subnet_group_name  = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids = [var.redis_elasticache_sg_id]
  
  num_cache_clusters = 1
  
  parameter_group_name       = aws_elasticache_parameter_group.redis_parameter_group.name
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  
  automatic_failover_enabled = var.cache_config.auotmatic_failover_enabled
  multi_az_enabled           = var.cache_config.multi_az_enabled

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-redis-cluster"
    }
  )
}