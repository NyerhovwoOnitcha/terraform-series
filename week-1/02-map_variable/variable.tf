variable "access_key" {
  default = "mykey"
}

variable "secret_key" {
  default = "mykey"
}

variable "tag_name" {
  default = "main-vpc"
}

variable "vpc-cidr" {
  default = "10.0.0.0/16"
}

#prefix-basename
#toto-basename
variable "basename" {
  description = "Prefix used for all resources names"
  default     = "nbo"
}

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