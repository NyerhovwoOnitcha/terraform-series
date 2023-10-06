provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "tooling_security_group" {
#   name        = "allow_http"
#   description = "Allow http inbound traffic"
  vpc_id      = vpc-0c32508cbb8ebe3d3 


  tags = {
    Name = "allow_http"
  }
}