terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

resource "aws_instance" "Terraform-instance" {
  ami = "ami-0261755bbcb8c4a84"
  instance_type = "t2.micro"
}