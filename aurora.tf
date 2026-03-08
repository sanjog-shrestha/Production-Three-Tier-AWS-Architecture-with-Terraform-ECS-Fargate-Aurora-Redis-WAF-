# Subnet group restricting Aurora to the private DB subnets.
resource "aws_db_subnet_group" "aurora" {
  name = "${var.project_name}-aurora-subnet-group"
  subnet_ids = [
    aws_subnet.private_db_1.id,
    aws_subnet.private_db_2.id
  ]
}

# Cluster parameter group for Aurora MySQL (tuning + charset defaults).
resource "aws_rds_cluster_parameter_group" "aurora" {
  family = "aurora-mysql8.0"
  name   = "${var.project_name}-aurora-params"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }

}

# Aurora MySQL Serverless v2 cluster for the application database.
resource "aws_rds_cluster" "aurora" {
  cluster_identifier              = "${var.project_name}-aurora-cluster"
  engine                          = "aurora-mysql"
  engine_version                  = "8.0.mysql_aurora.3.04.0"
  database_name                   = "appdb"
  master_username                 = "adminuser"
  master_password                 = "ChangeMe!Securely123"
  db_subnet_group_name            = aws_db_subnet_group.aurora.name
  vpc_security_group_ids          = [aws_security_group.aurora.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 16
  }

  availability_zones = [
    "${var.aws_region}a",
    "${var.aws_region}b"
  ]

  backup_retention_period = 7
  preferred_backup_window = "02:00-03:00"

  storage_encrypted   = true
  deletion_protection = false

  preferred_maintenance_window = "sun:04:00-sun:05:00"

  skip_final_snapshot = true
  apply_immediately   = true
}

# Writer instance for the Aurora cluster (Serverless v2 uses db.serverless class).
resource "aws_rds_cluster_instance" "writer" {
  identifier         = "${var.project_name}-aurora-writer"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
}

# Reader instance for the Aurora cluster (Serverless v2 uses db.serverless class).
resource "aws_rds_cluster_instance" "reader" {
  identifier         = "${var.project_name}-aurora-reader"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
}
