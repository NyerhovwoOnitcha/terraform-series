resource "aws_instance" "website_bucket" {
  ami           = "XXXX"
  instance_type = "t2.micro"
}

resource "aws_instance" "firefox_bucket" {
  ami           = "XXXXX"
  instance_type = "t2.micro"
}   