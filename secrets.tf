# ------------------------------------------------------------------------------
# secrets.tf — AWS Secrets Manager and IAM for Aurora DB credentials.
# ------------------------------------------------------------------------------

# Secret placeholder in Secrets Manager; the actual credentials are stored in a secret version.
resource "aws_secretsmanager_secret" "aurora_credentials" {
  name        = "${var.project_name}/aurora/credentials"
  description = "Aurora MySQL master credentials for ${var.project_name}"

  tags = {
    Name        = "${var.project_name}-aurora-credentials"
    Environment = var.environment
  }
}

# Store Aurora username, password, host, port, and dbname as a JSON secret string.
resource "aws_secretsmanager_secret_version" "aurora_credentials" {
  secret_id = aws_secretsmanager_secret.aurora_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    engine   = "aurora-mysql"
    host     = aws_rds_cluster.aurora.endpoint
    port     = 3306
    dbname   = "appdb"
  })

  depends_on = [aws_rds_cluster.aurora]
}

# Data source to read the current secret version (e.g. for reference or drift checks).
data "aws_secretsmanager_secret_version" "aurora_credentials" {
  secret_id  = aws_secretsmanager_secret.aurora_credentials.id
  depends_on = [aws_secretsmanager_secret_version.aurora_credentials]
}

# Allow ECS execution role to read Aurora credentials from Secrets Manager.
resource "aws_iam_role_policy" "secrets_manager_read" {
  name = "${var.project_name}-secrets-manager-read"
  role = aws_iam_role.ecs_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.aurora_credentials.arn
      }
    ]
  })
}