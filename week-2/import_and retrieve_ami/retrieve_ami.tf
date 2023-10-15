provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ecs_optimized_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.202*-x86_64-ebs"]
  }
}


resource "aws_instance" "app" {
  ami           = data.aws_ami.ecs_optimized_ami.id
  instance_type = "t2.micro"
}