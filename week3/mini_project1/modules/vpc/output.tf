# Outputs the id of the subnet you created in the module
output "subnet_id" {
  value = aws_subnet.this.id
}
# Outputs the value of the 
# /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 parameter.
output "ami_id" {
  value = data.aws_ami.ubuntu.image_id
}