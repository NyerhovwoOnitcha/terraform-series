provider "aws" {
  region = var.aws_region
}

module "my_instance_module" {
  source        = "../modules/ec2"
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"
  instance_name = "myvm01"
} 