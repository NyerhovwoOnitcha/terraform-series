- [Week 1: Lists and Map Variables](#week-1--lists-and-map-variables)
  * [Map Variable](#map-variable)
  * [02 Map Variable: Combinig `for each` and `map variables`](#02-map-variable--combinig--for-each--and--map-variables-)
  * [List Variable](#list-variable)





# Week 1: Lists and Map Variables

## Map Variable

```
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
```

The map variable maps one variable to another, in the example above you want to create an instance, when you run tf apply you will prompted to give a value for the variable region since you declared it as a blank variable.
if you choose `us-east-1`, terraform will create the instance using the ami in us-east-1 thereby mapping one variable i.e amis variable to the another i.e the region variable

## 02 Map Variable: Combinig `for each` and `map variables`

In this scenario we want to create multiple subnets, so a `variable.tf` file is created for the variable called `prefix` that maps each subnet with it's attribute:

```
variable "prefix" {
  type = map(any)
  default = {
    sub-1 = {
      az   = "use1-az1"
      cidr = "10.0.198.0/24"
    }
    sub-2 = {
      az   = "use1-az2"
      cidr = "10.0.199.0/24"
    }
    sub-3 = {
      az   = "use1-az3"
      cidr = "10.0.200.0/24"
    }
  }
}
```
Then the `for each` function is used. It basically says `for each` subnet in `var.prefix`, get the corresponding value for the `az and cidr`

Note: For each is used with maps or set of strings and not lists

```
resource "aws_vpc" "main-vpc" {
  cidr_block = var.vpc-cidr

  tags = {
    Name = var.tag_name
  }
}

resource "aws_subnet" "main-subnet" {
  for_each = var.prefix

  availability_zone_id = each.value["az"]
  cidr_block           = each.value["cidr"]
  vpc_id               = aws_vpc.main-vpc.id

  tags = {
    Name = "${var.basename}-subnet-${each.key}"
  }
}
```

## List Variable

```
variable "users" {
    type = list(string)
    default = [ "sadiq", "maniq", "tariq"  ]
}
```
In this scenario we want to create **IAM users** for multiple people, we can use `lists`.
We first declare a `variable called "users" with type = lists` and proceed to give a list of names that will be used to create IAM users.
Then we call the list in the `main.tf` file

```
resource "aws_iam_user" "create_users" {
  count = length(var.users)
  name = var.users[count.index]
}
```
The count argument there counts the number of users in the variable `users` and creates them one by one, with the count argument terraform knows to stop after creating the last user `tariq` as it knows that the count end there.
