# ------------------------------------------------------------------------------
# redis.tf — ElastiCache Redis replication group (Multi-AZ), subnet and parameter groups.
# ------------------------------------------------------------------------------

# Subnet group restricting Redis to the private DB subnets.
resource "aws_elasticache_subnet_group" "redis" {
  name = "${var.project_name}-redis-subnet-group"
  subnet_ids = [
    aws_subnet.private_db_1.id,
    aws_subnet.private_db_2.id
  ]
}

# Parameter group for Redis settings (eviction policy, etc.).
resource "aws_elasticache_parameter_group" "redis" {
  family = "redis7"
  name   = "${var.project_name}-redis-params"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }
}

# Redis replication group (Multi-AZ with automatic failover).
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${var.project_name}-redis"
  description          = "Redis cache cluster for ${var.project_name}"

  node_type            = "cache.t3.micro"
  port                 = 6379
  parameter_group_name = aws_elasticache_parameter_group.redis.name
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]

  num_cache_clusters         = 2
  automatic_failover_enabled = true
  multi_az_enabled           = true

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  maintenance_window       = "sun:05:00-sun:06:00"
  snapshot_retention_limit = 7
  snapshot_window          = "03:00-04:00"

  apply_immediately = true
}