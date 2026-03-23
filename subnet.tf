# ------------------------------------------------------------------------------
# subnet.tf — Public, private app, and private DB subnets across two AZs.
# ------------------------------------------------------------------------------

# Public subnet (AZ a) for internet-facing resources (e.g., ALB/NAT).
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
}

# Public subnet (AZ b) for internet-facing resources (e.g., ALB/NAT).
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
}

# Private application subnet (AZ a) for ECS tasks (no public IPs).
resource "aws_subnet" "private_app_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "${var.aws_region}a"
}

# Private application subnet (AZ b) for ECS tasks (no public IPs).
resource "aws_subnet" "private_app_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "${var.aws_region}b"
}

# Private data subnet (AZ a) for cache + database.
resource "aws_subnet" "private_db_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "${var.aws_region}a"
}

# Private data subnet (AZ b) for cache + database.
resource "aws_subnet" "private_db_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "${var.aws_region}b"
}
