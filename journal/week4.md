# Week 4: 

### S3 Bucket Website hosting Module

The `static_website_mod dir` contains a module that deploys an s3 bucket along with policies that allows public access to the object in the modules.

You will observe that some important parameters that may need to be changed according to the environment that the module is called in e.g `bucket name, index.html file path and error.html file path,` are not hardcoded, they are declared as blank variables  in the module and their values are inputed when the module is called.

### For Each Loop with Local exec

For objects uploaded to the s3 bucket, The command below is used to update its ACL for public read access:

# https://repost.aws/knowledge-center/read-access-objects-s3-bucket
`aws s3api put-object-acl --bucket DOC-EXAMPLE-BUCKET --key exampleobject --acl public-read`

To run this command for every object in the s3 bucket a **for each** loop is used

First you declare a local variable that takes the commands as inputs, then you create a null resource inside which we call the local-exec provisioner to loop over the commands.

```
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
```