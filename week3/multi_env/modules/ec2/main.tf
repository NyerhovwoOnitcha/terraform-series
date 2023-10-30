resource "aws_instance" "my_instance" {
	ami = var.ami
	instance_type = var.instance_type
    key_name = var.key_name
	tags = {
		Name = var.instance_name	
	}
}