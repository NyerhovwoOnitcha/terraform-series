provider "aws" {
  region = "us-east-1"
}

# The count argument there counts the number of users in the variable `users` and creates them one by one
resource "aws_iam_user" "create_users" {
  count = length(var.users)
  name = var.users[count.index]
}