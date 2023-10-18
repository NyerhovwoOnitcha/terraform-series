/*

VPC MODULE BEGINS
==================

# Binds the variable to the value of var.main_region.
variable "main_region" {
  type    = string
  default = "us-east-2"
}
# Binds the value of the variable to the AWS region.
provider "aws" {
  region = var.main_region
}
# Calls the code in the vpc module you created earlier.
module "vpc" {
  source = "./modules/vpc"
  region = var.main_region
}
resource "aws_instance" "my-instance" {
  # Binds the value of the ami variable to the AMI id in this module.
  ami = module.vpc.ami_id
  # Binds the value of the subnet id to the subnet id in the module.
  subnet_id = module.vpc.subnet_id
  # Binds the value of instance type to t2.micro.
  instance_type = "t2.micro"
}

VPC MODULE ENDS
============================================================================================
*/

#==================================================
# EC2 MODULE BEGINS

provider "aws" {
  region = var.aws_region
}

module "my_instance_module" {
  source        = "./modules/ec2"
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  instance_name = "myvm01"
}

#==================================================
# EC2 MODULE ENDS


