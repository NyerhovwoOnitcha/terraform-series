provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

#Create Bucket
resource "aws_s3_bucket" "prod_tf_course" {
  bucket = "cnl-community-2023-01-14"
}

#Enforce Bucket Ownership
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl
resource "aws_s3_bucket_ownership_controls" "bucket_owner" {
  bucket = aws_s3_bucket.prod_tf_course.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Set Bucket ACL to private

resource "aws_s3_bucket_acl" "private_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_owner]

  bucket = aws_s3_bucket.prod_tf_course.id
  acl    = "private"
}


# Use Default VPC
resource "aws_default_vpc" "default" {}


# Create Security Group
resource "aws_security_group" "prod_web" {
  name        = "prod_web"
  description = "allow standard http and https ports inbound everything outbound"

  tags = {
    "Terraform" : "true"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
#specifies an inbound group for your security group in a VPC
resource "aws_vpc_security_group_ingress_rule" "http_inbound_rule" {
  security_group_id = aws_security_group.prod_web.id

  description = "from my ip range"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"

}

resource "aws_vpc_security_group_ingress_rule" "https_inbound_rule" {
  security_group_id = aws_security_group.prod_web.id

  description = "from my ip range"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule
#specifies an outbound rule for your security group in a VPC
resource "aws_vpc_security_group_egress_rule" "outbound_egress" {
  security_group_id = aws_security_group.prod_web.id

  from_port   = "0"
  to_port     = "0"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

}


resource "aws_instance" "prod_web" {
  ami           = "ami-0172ac545704d6915"
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.prod_web.id
  ]

  tags = {
    "Terraform" : "true"
  }
}

resource "aws_eip" "prod_web" {
  instance = aws_instance.prod_web.id

  tags = {
    "Terraform" : "true"
  }
}
