output "private_subnet1" {
  value = aws_subnet.private_subnets.*.id
  
}