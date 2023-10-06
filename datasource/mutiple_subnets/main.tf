provider "aws" {
  region = "us-east-1"
}

/*# 1- using datasource to create subnets
variable "vpc_id" {}

data "aws_vpc" "papi_vpc" {
  value = var.vpc_id.id
}

output "my_vpc_id" {
  value = data.aws_vpc.papi_vpc.id
}

resource "aws_subnet" "example" {
  vpc_id            = data.aws_vpc.papi_vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = cidrsubnet(data.aws_vpc.papi_vpc.cidr_block, 4, 2)
}

*/


# 2- using datasource to create multiple subnets

# resource "aws_vpc" "prod-vpc" {
#   cidr_block       = var.vpc-cidr
#   instance_tenancy = "default"

#   tags = {
#     Name = "main"
#   }
# }

# resource "aws_subnet" "public_subnets" {
#  count      = length(var.public_subnet)
#  vpc_id     = aws_vpc.prod-vpc.id
#  cidr_block = element(var.public_subnet, count.index)
# }

# This can also work:

# resource "aws_subnet" "pub_sub" {
#   vpc_id     = var.vpc_id
#   count      = length(var.public_subnet)
#   cidr_block = var.public_subnet[count.index]         
# }

# resource "aws_subnet" "private_subnets" {
#  count      = length(var.private_subnet)
#  vpc_id     = aws_vpc.prod-vpc.id
#  cidr_block = element(var.private_subnet, count.index)
#  tags = {
#     Tier = "Private"
#   }
# }




