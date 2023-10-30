# Week 4: 
- **S3 Bucket static Website hosting Module**
- **Application Load Balancer Module**
<!-- - **EC2 module (mini_project1)**
- **Using Module in multi environment**
- **Multi Folder Module** -->



## S3 Bucket static Website hosting Module

The `static_website_mod dir` contains a module that deploys an s3 bucket along with policies that allows public access to the object in the modules.

You will observe that some important parameters that may need to be changed according to the environment that the module is called in e.g `bucket name, index.html file path and error.html file path,` are not hardcoded, they are declared as blank variables  in the module and their values are inputed when the module is called.

### PutBucketPolicy 

https://docs.aws.amazon.com/AmazonS3/latest/userguide//using-with-s3-actions.html

After creation of the s3 buckets, to add policies to the bucket the caller identity configured in your cli must have **PutBucketPolicy** permission. If this is not done you will receive an `Access Denied error` any time you carry out actions that requires the user to have PutBucketPolicy permission e.g adding an ACL policy to objects in the bucket

### Set Bucket Ownership and make allow Public access to the Bucket

 https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl


### Update ACL of objects in s3 buckets for public read Access

For objects uploaded to the s3 bucket, The command below is used to update its ACL for public read access:

 https://repost.aws/knowledge-center/read-access-objects-s3-bucket

`aws s3api put-object-acl --bucket DOC-EXAMPLE-BUCKET --key exampleobject --acl public-read`

### For Each Loop with Local exec

Running the command for every object in the bucket might be tiresome especially if there are more than 1 objects, a **for each** loop and the **local-exec provisioner** can be used

First:
-  `declare a local variable` that takes all the commands as inputs 

- `Create a null resource` inside which we call the local-exec provisioner to loop over the commands.

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

## Application Load Balancer Module

- This module creates a VPC, 3 subnets in 3 different AZ and sets the routing
- Creates a security with inbound and outbound rules 
- Creates 3 instances, each within the 3 subnets and in the VPC created above. The instances are bootstrapped with nginx and some commands
- Creates a target group, attaches the 3 instances as targets, creates a LB, creates a LB listener that attaches the target group to the LB. 
- outputs the loadbalancer DNS name

## Nginx

![Task Overview](./images/launch_nginx_project_overview%20.jpg)
- This block creates an s3 bucket and makes it private
- Creates a security group and sets the ingress(http and https) and egress rule
- Creates an instance in the default vpc using the nginx ami-id
- Assigns an elastic ip to the instance

## Lambda

### Lambda_aws_start

If you are familiar with lambda, you must know lambda functions require  an IAM role which must have some permissions.

The `Lambda_aws_start` tf files uses a Pyhton runtime to start instances.
- The `iam.tf` file creates an IAM role, the required policies/permissions and attaches the policies to the role
- The `data block` of the `resource.tf` file first saves the python code in the resource `archive file`

- The `aws_lambda_function` resource calls the lambda function
- The `aws_cloudwatch_event_rule` resource sets a cloudwatch rule that triggers the lambda function
- The `aws_cloudwatch_event_target` feeds the `aws_lambda_function` as the target to the  `aws_cloudwatch_event_rule`
- The `aws_lambda_permission` gives the permissions necessary

Learn more about the python script that starts and stops instances
 https://aws.amazon.com/premiumsupport/knowledge-center/start-stop-lambda-cloudwatch/

 https://www.slsmk.com/using-python-and-boto3-to-get-instance-tag-information/

### Cron expressions for your cloudwatch
https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cron-expressions.html

`tf plan -var-file=variable.tfvars`

### Lambda_aws_stop

This function stops specified running instances

### aws ec2 tag mails

Tags and labels are important as they give you a greater level of control and flexibility to manipulate resources. In cases where resources are deployed without tags, we can configure a mail to alert to us to correct this anomaly