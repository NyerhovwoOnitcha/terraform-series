output "vpc_id" {

  value = aws_vpc.vijayprod.id
}

output "public_subnet" {

  value = aws_subnet.public_subnet.id
}