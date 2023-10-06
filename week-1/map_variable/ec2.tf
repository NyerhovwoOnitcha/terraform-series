variable "region" {}
variable "amis" {
  type = map(string)
  default = {
    "us-east-1" = "ami-0b0dcb5067f052a63"
    "us-east-2" = "ami-0185a6f76b69a1870"
  }
}

resource "aws_instance" "example" {
  ami           = lookup(var.amis, var.region)
  instance_type = "t2.micro"
}

# The map variable maps one variable to another, in the example above you want to create an instance, 
# when you run tf apply you will prompted to give a value for the variable region since you declared it as a blank variable
# if you choose `us-east-1`, terraform will create the instance using the ami in us-east-1 
# Thereby mapping one variable i.e amis variable to the another i.e the region variable