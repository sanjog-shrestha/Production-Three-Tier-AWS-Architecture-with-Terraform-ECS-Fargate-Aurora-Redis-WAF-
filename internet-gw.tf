# Internet Gateway to provide internet access for public subnets (and NAT gateways).
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

}