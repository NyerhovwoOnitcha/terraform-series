# This variable is not hardcoded, the value will be passed/
# when the module is called in the project root's main.tf file
variable "bucket_name" {
  description = "Name of the s3 bucket. Must be unique."
  type = string
}

variable "tags" {
 
  type = map(string)
  default = {}
}

variable "index_html_filepath" {
  
  type = string
  
}

variable "error_html_filepath" {
  
  type = string
  
}

variable "index_html_key" {
  type = string
}

variable "error_html_key" {
  type = string
}


