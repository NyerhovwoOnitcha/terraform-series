terraform {
  required_providers {
    archive = "~> 1.3"
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/python/main.py"
  output_path = "${path.module}/python/main.py.zip"
}

resource "aws_lambda_function" "lambdaFn" {
  filename      = "${path.module}/python/main.py.zip"
  function_name = var.lambdaname
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.8"

  environment {
    variables = {
      region      = var.region
      fromAddress = var.fromAddress
    }
  }
}

resource "aws_cloudwatch_event_rule" "minitues" {
  name                = "${var.lambdaname}-event-rule"
  description         = "7-00 PM Monday through Fridays"
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule      = aws_cloudwatch_event_rule.minitues.name
  target_id = "lambda"
  arn       = aws_lambda_function.lambdaFn.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambdaFn.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.minitues.arn
}

resource "aws_ses_email_identity" "ses" {
  email = var.fromAddress
}