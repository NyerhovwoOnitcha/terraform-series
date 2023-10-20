provider "aws" {
  region = "us-east-1"
}


module "s3_static_website" {
  source = "./module/s3_static_website"

  bucket_name         = "papisecuritylalapapabucket"
  index_html_filepath = "/mnt/c/Users/HP/Desktop/terraform-series/static_website_mod/module/s3_static_website/www/index.html"
  error_html_filepath = "/mnt/c/Users/HP/Desktop/terraform-series/static_website_mod/module/s3_static_website/www/error.html"
  index_html_key      = "index.html"
  error_html_key      = "error.html"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}