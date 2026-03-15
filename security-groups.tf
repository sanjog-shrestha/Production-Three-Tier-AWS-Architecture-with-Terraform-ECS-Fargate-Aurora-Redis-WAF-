# ------------------------------------------------------------------------------
# security-groups.tf — Security groups for ALB, ECS, Redis, and Aurora.
# ------------------------------------------------------------------------------

# Security group for the ALB (ingress from the internet, egress to targets).
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Controls traffic from internet to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from Intenret"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from Intenret"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound "
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for ECS tasks (ingress only from the ALB, egress to dependencies).
resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-ecs-sg"
  description = "Controls traffic from ALB to ECS containers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow HTTP from Internet"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for Redis (ingress only from ECS tasks).
resource "aws_security_group" "redis" {
  name        = "${var.project_name}-redis-sg"
  description = "Controls traffic from ECS to redis"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow Redis port from ECS only"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for Aurora MySQL (ingress only from ECS tasks).
resource "aws_security_group" "aurora" {
  name        = "${var.project_name}-aurora-sg"
  description = "Controls traffic from ECS to Aurora"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow MySQL port from ECS only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
