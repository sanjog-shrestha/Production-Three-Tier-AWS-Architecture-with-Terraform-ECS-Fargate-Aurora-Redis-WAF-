# ------------------------------------------------------------------------------
# nat-gw.tf — NAT Gateways and Elastic IPs for private subnet outbound internet access.
# ------------------------------------------------------------------------------

# Elastic IP for NAT Gateway in public subnet (AZ a).
resource "aws_eip" "nat_1" {
  domain = "vpc"
}

# Elastic IP for NAT Gateway in public subnet (AZ b).
resource "aws_eip" "nat_2" {
  domain = "vpc"
}

# NAT Gateway (AZ a) to allow private subnets outbound internet access.
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_1.id
  depends_on    = [aws_internet_gateway.main]
}

# NAT Gateway (AZ b) to allow private subnets outbound internet access.
resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_2.id
  depends_on    = [aws_internet_gateway.main]
}