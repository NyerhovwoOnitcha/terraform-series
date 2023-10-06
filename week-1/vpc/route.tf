# create public route table and edit the public route to point all traffic to internet gateway

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.tooling.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tooling_gw.id
  }

  tags = {
    Name = "public_route"
  }
}

# Associate subent to pulic route table
resource "aws_main_route_table_association" "public_subnet_assoc" {
  vpc_id         = aws_vpc.tooling.id
  route_table_id = aws_route_table.public-rt.id
}



# create private route and edit private route to point all traffic from towards nat-gateway
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.tooling.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tooling_nat_gateway.id
  }

  tags = {
    Name = "private_route"
  }
}

# Associate private subnet to private route table
resource "aws_main_route_table_association" "private_subnet_assoc" {
  vpc_id         = aws_vpc.tooling.id
  route_table_id = aws_route_table.private-rt.id
}
