# ------------------------------------------------------------------------------
# outputs.tf — Terraform outputs exposed after apply (URLs, endpoints, IDs).
# ------------------------------------------------------------------------------

# [UPDATED - CloudFront] Primary HTTPS URL via CloudFront.
# Fully trusted certificate, no browser warning.
# Wait 5–10 minutes after apply for CloudFront global propagation.
output "app_url" {
  description = "HTTPS URL via CloudFront — trusted certificate, no browser warning"
  value       = "https://${aws_cloudfront_distribution.app.domain_name}"
}

# [NEW - CloudFront] Raw CloudFront domain name — for DNS records or CI/CD.
output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.app.domain_name
}

# [NEW - CloudFront] Distribution ID — for cache invalidation in CI/CD pipelines.
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID — use for cache invalidation in CI/CD"
  value       = aws_cloudfront_distribution.app.id
}

# ALB DNS name — internal origin used by CloudFront. Use app_url to access the app.
output "alb_dns_name" {
  description = "Raw ALB DNS name — internal origin, use app_url instead"
  value       = aws_lb.main.dns_name
}

# ECS cluster name.
output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.main.name
}

# CloudWatch Log Group used by the ECS task definition.
output "cloudwatch_log_group" {
  description = "CloudWatch log group for container logs"
  value       = aws_cloudwatch_log_group.ecs.name
}

# [FIXED] Typo corrected: "redis_priamry_endpoint" → "redis_primary_endpoint"
output "redis_primary_endpoint" {
  description = "Redis primary endpoint for write operations"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

# Redis reader endpoint for read operations.
output "redis_reader_endpoint" {
  description = "Redis reader endpoint for read operations"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

# Redis port.
output "redis_port" {
  description = "Redis port"
  value       = 6379
}

# Aurora writer endpoint.
output "aurora_writer_endpoint" {
  description = "Aurora writer endpoint for all write operations"
  value       = aws_rds_cluster.aurora.endpoint
  sensitive   = true
}

# Aurora reader endpoint.
output "aurora_reader_endpoint" {
  description = "Aurora reader endpoint for read scaling"
  value       = aws_rds_cluster.aurora.reader_endpoint
  sensitive   = true
}

# Aurora database name.
output "aurora_database_name" {
  description = "Aurora database name"
  value       = aws_rds_cluster.aurora.database_name
}

# Aurora port.
output "aurora_port" {
  description = "Aurora port"
  value       = aws_rds_cluster.aurora.port
}

# VPC ID.
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

# Public subnet IDs.
output "public_subnet_ids" {
  description = "Public subnet IDs (web tier)"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

# Private app subnet IDs.
output "private_app_subnet_ids" {
  description = "Private app subnet IDs (application tier)"
  value       = [aws_subnet.private_app_1.id, aws_subnet.private_app_2.id]
}

# Private DB subnet IDs.
output "private_db_subnet_ids" {
  description = "Private DB subnet IDs (cache and database tier)"
  value       = [aws_subnet.private_db_1.id, aws_subnet.private_db_2.id]
}

# Secrets Manager ARN for Aurora credentials.
output "aurora_secret_arn" {
  description = "Secrets Manager ARN for Aurora credentials — use in app config and CI/CD"
  value       = aws_secretsmanager_secret.aurora_credentials.arn
}