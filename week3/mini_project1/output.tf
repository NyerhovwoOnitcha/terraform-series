/*
VPC MODULE BEGINS
==================

# Print out the private ip of the EC2 instance that will be created using this module
output "PrivateIP" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.my-instance.private_ip
}

VPC MODULE ENDS
============================================================================================
*/


# EC2 MODULE BEGINS
# ======================================

output "instance_ip_addr" {
  value       = module.my_instance_module.instance_ip_addr
  description = "The public IP address of the main instance."
}

# EC2 MODULE ENDS
# ======================================