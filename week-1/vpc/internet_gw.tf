resource "aws_internet_gateway" "tooling_gw" {
  vpc_id = aws_vpc.tooling.id

  tags = {
    Name = "tooling_IGW"
  }
}

