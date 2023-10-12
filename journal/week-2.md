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

[Terraform Backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)

The backend i.e your statefile can be stored in terraform cloud or in s3 bucket, this is in case your local env crashes you will not lose your statefile or in scenarios where you are part of a team and everyone in the team will need the updated statefile.

For now we will store our backend in s3 bucket.

A Dynamo DB table will also be created, why?

Well, imagine you are working as a part of a team using github as the SCM of choice where all the project files are stored and the statefile of the project is in a s3 bucket, you need to enable state locking, Dynamo DB does this.

For many projects Terraform auto-deploys from the SCM, so if there's any push to the SCM, it takes the statefile and auto-deploys it.

If member A is working on his end and pushes to the project Repo, while terraform plans and auto-deploys the resoures in the updated statefile there should be a lock on the repo so that member B on his end or any other member of the team cannot push to the same repo(thus modifying the statefile) until terraform applies the changes from member A. 

we use a central DynamoDB table to manage state locking thus ensuring that only one user or process is modifying the state file at any given time, preventing conflicts and ensuring consistency.
Member B on his end must first run `terraform state pull` to get the latest version of the statefile before modifying and pushing his update to the project repo.



**You will implemnent migrating your backend from your local workspace to a remote s3 bucket with state lock enabled.**

To do this:

#### First create the s3 bucket and a dynamo DB table where the statefile will be stored

```
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "my_s3" {
  bucket = "a1citybnaksjksajijweklidal112"

  tags = {
    Name = "local_state_bucket"

  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.my_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

```

```
resource "aws_dynamodb_table" "basic-dynamodb-table-papi" {
  name         = "GameScores"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }




  tags = {
    Name = "basic-dynamodb-table-papi"
  }
}
```
#### Next create an ec2 instance to create the local statefile which will be migrated. This statefile will be migrated to the s3 bucket.

```
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
}
```
#### Next create a `backend.tf`. The configuration tells terraform to migrate the statefile to the s3 bucket specified and use it onwards with a key lock enabled

```
terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket = "a1citybnaksjksajijweklidal112"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "GameScores"
    encrypt        = true
  }
}
```

Run `terraform init` to re-initialize the backend. You should get the output below

```
Initializing the backend...
Acquiring state lock. This may take a few moments...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend. Do you want to copy this state to the new "s3"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: 
```

Answer the prompt with `yes` to initialize the backend. The output below:

```

Releasing state lock. This may take a few moments...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v5.19.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

#### You just successfully migrated a statefile from local to s3 bucket

## Remote exec

Say you want to create an instance and run some commands on the instance, remote exec will do this just fine. example is the code below that creates an instance, copy your public key to the instance to allow connection and installs some packages on the instance

```
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_key_pair" "example" {
  key_name   = "examplekey"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "example" {
  key_name      = aws_key_pair.example.key_name
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras enable nginx1.12",
      "sudo yum -y install nginx",
      "sudo systemctl start nginx"
    ]
  }
}
```
## File Provisioners

Provisioners allow you to execute commands on compute instances, say you want to do something like invalidate cache, terraform doesn't have a particular provision for this, a workaround is to find a way to execute the command locally on your server to invalidate cache or remotely. Provisioners allow you to do this, they allow you execute commands on your AWS CLI. 

Thus the remote-exec used above is a provisioner.

A case where the **local-exec provisioner** was used to invalidate cash can be seen [here](https://github.com/NyerhovwoOnitcha/terraform-beginner-bootcamp-2023/blob/main/journal/week1.md#provisioners) 

In this scenario today, we will use both the **remote-exec provisioner** and **file provisioner**

**The code creates an AWS instance, the path to the public key on your pc is specified and used to create the *aws_key_pair resource*. This key is specified when creating the instance to enable you ssh into the instance from your pc**

The connection block specifies the ssh connection

The **remote-exec (Provisioner)block** installs httpd

The **file Provisioner block** copies an index.html file from your local pc to the webservers root dir.

- **NOTE**- Your will observe that in this scenario the provisioner is part of a resource, a provisioner may be part of a resource, an example is seen [here](https://github.com/NyerhovwoOnitcha/terraform-beginner-bootcamp-2023/blob/main/journal/week1.md#provisioners) where the provisioner is a standalone resource that is trigerred by something.


```
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_key_pair" "example" {
  key_name   = "examplekey"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "example" {
  key_name      = aws_key_pair.example.key_name
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install epel -y",
      "sudo yum install httpd -y",
      "sudo chmod -Rf 777 /var/www/html",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"

    ]
  }
  provisioner "file" {
    source      = "index.html"
    destination = "/var/www/html/index.html"
  }

}
```