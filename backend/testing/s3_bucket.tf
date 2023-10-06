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


/*
resource "aws_s3_bucket_policy" "backend_permission_policy" {
  bucket = aws_s3_bucket.my_s3.id
  policy = jsonencode({

    "Version"= "2012-10-17",
    "Statement"= [ {
      "Effect"= "Allow",
      "Action"= "s3:ListBucket",
      "Resource"= "arn:aws:s3:::mybucket"
    },
    {
      "Effect"= "Allow",
      "Action"= ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource"= "arn:aws:s3:::mybucket/path/to/my/key"
    }]
  })
}


resource "aws_s3_bucket_policy" "backend_dynamo_policy" {
  bucket = aws_s3_bucket.my_s3.id
  policy = jsonencode({

    "Version": "2012-10-17",
    "Statement": [
      {

        "Effect": "Allow",
        "Action": [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        "Resource": "arn:aws:dynamodb:*:*:table/mytable"
    }
    ]
  })
}
*/