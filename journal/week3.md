# Week 3: 
- **Modules**
- **Vpc Module (mini_project1)**
- **EC2 module (mini_project1)**
- **Using Module in multi environment**
- **Multi Folder Module**

## Modules

Module is basically refactoring your files to make them reusable in an efficient way. e.g instaed of just writing terraform code to create a VPC you can create a module that creates VPC, this module can be reused anytime by anyone. The best part is you can override the variables.

### VPC module
The `mini_project1` dir contains the modules dir. Different modules can be kept in this modules dir. The first is the VPC module that contains code to create a vpc in it's main.tf file as well as a variable.tf file and an output.tf file.

This VPC module is called in the project root's main.tf and output.tf file to create a vpc

Note how in the project's root main.tf file a new variable for region is defined (main_region) for us-east-2 , this variable will take precedence over the one set in the module's variable.tf file i.e default region = us-east 1. 
Thus you are calling the module but you are overriding the variables in the module.  This is how you use and reuse module in different environments

### EC2 module

You can clearly see here also that when the module is called in the dev environemnt's project dir, variables that overrides the ones set in the module are passed along

`project dir main.tf file`
```
module "my_instance_module" {
        source = "./my_modules/ec2"
        ami = "ami-053b0d53c279acc90"
        instance_type = "t2.micro"
        instance_name = "myvm01"
}
``` 
Each of these variables will override those already set in the module's variable.tf file below:

```
variable "ami" {
  type          = string
  default       = "ami-0b5eea76982371e91"
}

variable "instance_type" {
  type          = string
  default       = "t2-nano"
}

variable "instance_name" {
  description   = "Value of the Name tag for the EC2 instance"
  type          = string
  default       = "ExampleInstance"
}

variable "key_name" {
  type          = string
  default       = "hello"
}

```

### Using Module in a Multi Environment 

You can call a module in 2 environments e.g dev and sit and pass variables specific to each environment. The `multi_env dir` illustrates this.

You will observe that for each environment's variables are passed when the  module is called.

### Multi folder Module

In the VPC module the `vpc_cidr and subnet block variable` are left blank, this is because we will manully pass them when we call the module in the dev environment or any other environment.

**In the instance Module the `subnet id variable` is left blank also, we want the instance to be created in the VPC and the subnet created by the `vpc module` and not the default in the default vpc and a default subnet. This is important as it enables us create instance in our preferred VPC and subnet**


`module.my_vpc.public subnet` traces to the `public_subnet resource` of the vpc module. 

