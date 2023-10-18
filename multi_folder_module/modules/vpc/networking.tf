resource "aws_vpc" "vijayprod" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "vijayprod"
  }
}


resource "aws_subnet" "public_subnet" {

  vpc_id     = aws_vpc.vijayprod.id
  cidr_block = var.subnet_block
}