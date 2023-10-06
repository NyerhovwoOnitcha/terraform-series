# Week 2: 
- **Datasources**
- **Statefile Refresh**
- **Terraform Import**
- **Backend**
- **Remote Exec**
- **File Provisioner**
- **tf vars**


## Datasources
https://developer.hashicorp.com/terraform/language/data-sources

A data block requests that Terraform read from a given data source and export the result under a given local name. 

In the example below if you run `terraform apply` the terminal will prompt you to manually input the vpc id

**The data block reads the value you gave above and records, when you call the data under the output block it is able to present you with an output because it read and stored what you inputed as your `vpc_id`**



```
variable "vpc_id" {}

data "aws_vpc" "papi_vpc" {
  value = var.vpc_id.id
}

output "my_vpc_id" {
  value = data.aws_vpc.papi_vpc.id
}

resource "aws_subnet" "example" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = "us-east-1a"
  cidr_block        = cidrsubnet(data.aws_vpc.selected.cidr_block, 4, 2)
}
```

### Creating multiple subnets

This scenario creates multiple subnets. The variables are declared in the `variable.tf` file as seen below

```
variable "vpc-cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

```

The `main.tf` file creates the subnets

```
resource "aws_vpc" "prod-vpc" {
  cidr_block       = var.vpc-cidr
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet)
 vpc_id     = aws_vpc.prod-vpc.id
 cidr_block = element(var.public_subnet, count.index)
}

This can also work:

resource "aws_subnet" "pub_sub" {
  vpc_id     = var.vpc_id
  count      = length(var.public_subnet)
  cidr_block = var.public_subnet[count.index]         
}

resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet)
 vpc_id     = aws_vpc.prod-vpc.id
 cidr_block = element(var.private_subnet, count.index)
 tags = {
    Tier = "Private"
  }
}
```

In the `outputs.tf`, the '*' denotes all the private subnets:

```
output "private_subnet1" {
  value = aws_subnet.private_subnets.*.id
  
}
```

### Retrieving already created images IDs from your AWS account using the `data resource`

The code below allows you retrieve the a specific AMI from your aws account using filters/conditions specified to narrow down the options.

[This link](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html) shows you conditions/filters that can be used to describe Images

The result is stored in the `ecs_optimized_ami resource`  which is called and used to create a new instance

```
data "aws_ami" "ecs_optimized_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.202*-x86_64-ebs"]
  }
}


resource "aws_instance" "app" {
  ami           = data.aws_ami.ecs_optimized_ami.id
  instance_type = "t2.micro"
}
```

The command below helps you describe images, the command should be edited to suit the specific ami you want:
```
aws ec2 describe-images --owners amazon --filters "Name=platform,Values=windows" "Name=root-device-type,Values=ebs"
```

The command gives a result:
```
{
    "Images": [
        {
            "Architecture": "x86_64",
            "CreationDate": "2023-06-14T07:38:31.000Z",
            "ImageId": "ami-013142f5a3ca20f67",
            "ImageLocation": "amazon/Windows_Server-2016-English-Full-SQL_2014_SP3_Standard-2023.06.14",
            "ImageType": "machine",
            "Public": true,
            "OwnerId": "801119661308",
            "Platform": "windows",
            "PlatformDetails": "Windows with SQL Server Standard",
            "UsageOperation": "RunInstances:0006",
            "State": "available",
            "BlockDeviceMappings": [
                {
                    "DeviceName": "/dev/sda1",
-- More  -- 
```

From the optiosn above, you can take and configure a new filer/condition like this:

```
data "aws_ami" "ecs_optimized_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "OwnerId"
    values = ["801119661308"]
  }

  filter {
    name   = "ImageLocation"
    values = ["amazon/Windows_Server-2016-English-Full-SQL_2014_SP3_Standard-2023.06.14"]
  }

    filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "app" {
  ami           = data.aws_ami.ecs_optimized_ami.id
  instance_type = "t2.micro"
}
```

## STATEFILE REFRESH
If you create 2 s3 buckets from your terminal, this is updated in your state file.

If for some reason you delete one of the buckets from using the GUI and you want this deletion to reflect in the local state file run:

`terraform apply -refresh-only`

## Terraform Import

In this scenario you have 2 instances in yout GUI that you want to import to your state file. you will do this by

- CREATE RESOURCES WITH EMPTY VALUES
```
resource "aws_instance" "website_bucket" {
  ami           = "XXXX"
  instance_type = "t2.micro"
}

resource "aws_instance" "firefox_bucket" {
  ami           = "XXXXX"
  instance_type = "t2.micro"
}   
```

- Get the ami of the instances and Run the commands:
```
terraform import aws_instance.website_bucket i-0164af1aab5ffd692
terraform import aws_instance.firefox_bucket i-0d218bb949d0ee05c



AN s3 Bucket can be imported using the command:

terraform import aws_s3_bucket.bucket bucket-name

```

Both instances will be imported and mapped into the resources; website_bucket and firefox_bucket respectively and their ami will be updated in the local state file

## Backend

The backend i.e your statefile can be stored in terraform cloud or in s3 bucket, this is in case your local env crashes you will not lose your statefile or in scenarios where you are part of a team and everyone in the team will need the updated statefile.

For now we will store our backend in s3 bucket.

A Dynamo DB table will also be created, why?

Well, imagine you are working as a part of a team and the statefile of the project is in a s3 bucket, you need to enable state locking, Dynamo DB does this.

if member A is doing terraform apply and member B is doing terraform plan there will be a collsion, to avoid this when one member is running terraform plan there should be a lock on the statefile and member B will not be allowed to modify it until member A is done. 

we use a central DynamoDB table to manage state locking thus ensuring that only one user or process is modifying the state file at any given time, preventing conflicts and ensuring consistency.

`terraform init -lock=false` when initializing the backend