# Terraform configuration

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name

  tags = var.tags
}




resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.s3_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Upload index.html file to bucket above
resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.s3_bucket.id
  key    = var.index_html_key 
  source = var.index_html_filepath
  content_type = "text/html"
  
}

# Upload error.html file to bucket above
resource "aws_s3_object" "error_html" {
  bucket = aws_s3_bucket.s3_bucket.id
  key    = var.error_html_key 
  source = var.error_html_filepath
  content_type = "text/html"
}

# Grant Put permission to the user dave, the calling identity that will change the aws calling identity that will add the canned ACL policy to the objects in the s3 bucket
# must have the PutBucketPolicy permissions on the specified bucket and belong to the bucket owner's account in order to use this operation.
# If you don't have PutBucketPolicy permissions, Amazon S3 returns a 403 Access Denied error.

# https://docs.aws.amazon.com/AmazonS3/latest/userguide//using-with-s3-actions.html

resource "aws_s3_bucket_policy" "bucket_policy1" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = jsonencode({
    "Version"= "2012-10-17",
    "Statement"= [
        {
            "Sid"= "statement1",
            "Effect"= "Allow",
            "Principal"= {
                "AWS"= "arn:aws:iam::597081703771:user/terraform-user"
            },
            "Action"= [
            "s3:PutObject",
            "s3:PutObjectAcl"
            ],
            "Resource"= "arn:aws:s3:::${var.bucket_name}/*"
        }
    ]
  })
}


# The next 3 resources makes the bucket public
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl

resource "aws_s3_bucket_ownership_controls" "bucket_owner" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket_owner,
    aws_s3_bucket_public_access_block.public_access,
  ]

  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "public-read"
}

# resource "null_resource" "index_object_acl" {
#   provisioner "local-exec" {
#     command = "aws s3api put-object-acl --bucket ${var.bucket_name} --key ${var.index_html_key} --acl public-read"
#   }
# }

# resource "null_resource" "error_object_acl" {
#   provisioner "local-exec" {
#     command = "aws s3api put-object-acl --bucket ${var.bucket_name} --key ${var.error_html_key} --acl public-read"
#   }
# }



locals {
  commands = {
    "command1" = "aws s3api put-object-acl --bucket ${var.bucket_name} --key ${var.index_html_key} --acl public-read",
    "command2" = "aws s3api put-object-acl --bucket ${var.bucket_name} --key ${var.error_html_key} --acl public-read"
  }
}

resource "null_resource" "update_object_ACL" {
  for_each = local.commands

  provisioner "local-exec" {
    command = each.value
  }
}







