# ------------------------------------------------------------------------------
# outputs.tf — Terraform outputs exposed after apply (URLs, endpoints, IDs).
# ------------------------------------------------------------------------------

# Convenience URL for accessing the app through the ALB.
output "app_url" {
  description = "Full URL to access the application"
  value       = "http://${aws_lb.main.dns_name}"
}

# ALB DNS name (useful for troubleshooting / direct access checks).
output "alb_dns_name" {
  description = "Raw ALB DNS name"
  value       = aws_lb.main.dns_name
}

# ECS cluster name where the service runs.
output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.main.name
}

# CloudWatch Log Group used by the ECS task definition.
output "cloudwatch_log_group" {
  description = "CloudWatch log group for container logs"
  value       = aws_cloudwatch_log_group.ecs.name
}

# Redis primary endpoint for write operations.
output "redis_priamry_endpoint" {
  description = "Redis primary endpoint for write operations"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

# Redis reader endpoint for read operations.
output "redis_reader_endpoint" {
  description = "Redis primary endpoint for read operations"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

# Redis port for clients (ECS tasks) to connect to.
output "redis_port" {
  description = "Redis Port"
  value       = 6379
}

# Aurora writer endpoint for write operations.
output "aurora_writer_endpoint" {
  description = "Aurora writer endpoint for all write operations"
  value       = aws_rds_cluster.aurora.endpoint
  sensitive   = true
}

# Aurora reader endpoint for read scaling.
output "aurora_reader_endpoint" {
  description = "Aurora reader endpoint for all write operations"
  value       = aws_rds_cluster.aurora.reader_endpoint
  sensitive   = true
}

# Aurora database name created in the cluster.
output "aurora_database_name" {
  description = "Aurora Database name"
  value       = aws_rds_cluster.aurora.database_name
}

# Aurora port used by MySQL clients.
output "aurora_port" {
  description = "Aurora port"
  value       = aws_rds_cluster.aurora.port
}

# VPC ID for integration with other stacks/modules.
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

# Public subnet IDs used by internet-facing resources (ALB/NAT).
output "public_subnet_ids" {
  description = "Public Subnet Ids (Web Tier)"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

# Private app subnet IDs used by ECS tasks (application tier).
output "private_app_subnet_ids" {
  description = "Private app subnet IDS (Application Tier)"
  value       = [aws_subnet.private_app_1.id, aws_subnet.private_app_2.id]
}

# Private DB subnet IDs used by Redis and Aurora (data tier).
output "private_db_subnet_ids" {
  description = "Private DB subnet IDS (Cache + Database Tier)"
  value       = [aws_subnet.private_db_1.id, aws_subnet.private_db_2.id]
}

# Secrets Manager ARN for Aurora credentials; use in app config or CI/CD to fetch DB credentials.
output "aurora_secret_arn" {
  description = "Secrets Manager ARN for Aurora credentials — use in app config and CI/CD"
  value       = aws_secretsmanager_secret.aurora_credentials.arn
}
