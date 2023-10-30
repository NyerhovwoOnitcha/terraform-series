resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = "testserver"
  associate_public_ip_address = true

}