# ------------------------------------------------------------------------------
# route-tables.tf — Route tables and associations for public, app, and DB subnets.
# ------------------------------------------------------------------------------

# Route table for public subnets (default route to Internet Gateway).
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Associate public subnet (AZ a) with the public route table.
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# Associate public subnet (AZ b) with the public route table.
resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Route table for private app subnet (AZ a) with NAT Gateway for outbound access.
resource "aws_route_table" "private_app_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }
}

# Route table for private app subnet (AZ b) with NAT Gateway for outbound access.
resource "aws_route_table" "private_app_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2.id
  }
}

# Associate private app subnet (AZ a) with its route table.
resource "aws_route_table_association" "private_app_1" {
  subnet_id      = aws_subnet.private_app_1.id
  route_table_id = aws_route_table.private_app_1.id
}

# Associate private app subnet (AZ b) with its route table.
resource "aws_route_table_association" "private_app_2" {
  subnet_id      = aws_subnet.private_app_2.id
  route_table_id = aws_route_table.private_app_2.id
}

# Route table for private DB subnets (no direct internet route by default).
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id
}

# Associate private DB subnet (AZ a) with DB route table.
resource "aws_route_table_association" "private_db_1" {
  subnet_id      = aws_subnet.private_db_1.id
  route_table_id = aws_route_table.private_db.id
}

# Associate private DB subnet (AZ b) with DB route table.
resource "aws_route_table_association" "private_db_2" {
  subnet_id      = aws_subnet.private_db_2.id
  route_table_id = aws_route_table.private_db.id
}