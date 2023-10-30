# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "http-sg" {
  name        = "allow_http_access"
  description = "allow inbound http traffic"
  vpc_id      = aws_vpc.this.id

  tags = {
    "Name" = "Application-1-sg"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
#specifies an inbound group for your security group in a VPC
resource "aws_vpc_security_group_ingress_rule" "http-sg_ingress" {
  security_group_id = aws_security_group.http-sg.id

  description = "from my ip range"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule
#specifies an outbound rule for your security group in a VPC
resource "aws_vpc_security_group_egress_rule" "http-sg_egress" {
  security_group_id = aws_security_group.http-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = "0"
  ip_protocol = "-1"
  to_port     = "0"

}

data "aws_ami" "amazon_ami" {
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20220606.1-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
  owners      = ["amazon"]
}

resource "aws_instance" "app-server1" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.amazon_ami.id
  vpc_security_group_ids = [aws_security_group.http-sg.id]
  subnet_id              = aws_subnet.private-2a.id
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#associate_public_ip_address
  associate_public_ip_address = true
  tags = {
    Name = "app-server-1"
  }
  user_data = file("userdata/userdata.tpl")
}

resource "aws_instance" "app-server2" {
  instance_type               = "t2.micro"
  ami                         = data.aws_ami.amazon_ami.id
  vpc_security_group_ids      = [aws_security_group.http-sg.id]
  subnet_id                   = aws_subnet.private-2b.id
  associate_public_ip_address = true
  user_data                   = file("userdata/userdata.tpl")
  tags = {
    Name = "app-server-2"
  }
}
resource "aws_instance" "app-server3" {
  instance_type               = "t2.micro"
  ami                         = data.aws_ami.amazon_ami.id
  vpc_security_group_ids      = [aws_security_group.http-sg.id]
  subnet_id                   = aws_subnet.private-2c.id
  associate_public_ip_address = true
  user_data                   = file("userdata/userdata.tpl")
  tags = {
    Name = "app-server-3"
  }
}