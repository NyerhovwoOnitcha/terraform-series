# create elastic ip
resource "aws_eip" "toolingEIP" {
  domain = "vpc"
}

# create nat gateway and allocate elastic ip to it
resource "aws_nat_gateway" "tooling_nat_gateway" {
  allocation_id = aws_eip.toolingEIP.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "NAT-gw"
  }
}