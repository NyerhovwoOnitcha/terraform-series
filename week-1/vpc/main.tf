provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "tooling" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "tooling_vpc"
  }

}

