provider "aws" {
  region = var.aws_region
}

module "my_instance_module" {
  source        = "../modules/instance"
  ami           = "ami-0a606d8395a538502"
  instance_type = "t2.micro"
  instance_name = "sit-vijay"

}