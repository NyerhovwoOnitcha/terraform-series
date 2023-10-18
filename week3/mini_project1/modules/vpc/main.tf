# The provider block is where the parameters for this module are defined. 
# In this case, it defines a single parameter named region, 
# which  is the AWS Region where the VPC will be deployed.
provider "aws" {
  region = var.region
}

# This is a resource block and it's where you define VPC resources.
resource "aws_vpc" "this" {
  # This cidr_block defines the VPC as a 10.0.0.0/16 network. 
  # In other words, it's a 256 Class C (CIDR) IP address  range.
  cidr_block = "10.0.0.0/16"
}
# This is a resource block and it's where you define VPC resources.
resource "aws_subnet" "this" {
  # This line will bind the vpc_id to the vpc defined in the "aws_vpc" module.
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.0.1.0/24"
}
# This block defines a single parameter for this module 
# named /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical official
}