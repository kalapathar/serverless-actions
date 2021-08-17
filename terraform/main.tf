terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "personal"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "serverless-actions"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.test_bucket.id

  lambda_function {
    lambda_function_arn = module.lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "allow_bucket_lambda_alias" { 
  action  = "lambda:InvokeFunction"
  function_name  = module.lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.test_bucket.arn
}

data "archive_file" "lambda_zip" {
    type          = "zip"
    source_file   = "sample.py"
    output_path   = "lambda_function.zip"
}


module "lambda" {
  source           = "./modules/lambda"
  description      = "Example AWS Lambda using go with S3 trigger"
  filename         = "${path.module}/lambda_function.zip"
  function_name    = "serverless-actions"
  handler          = "sample.lambda_handler"
  runtime          = "python3.7"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"


  tags = {
    key = "value"
  }

  environment = {
    variables = {
      key = "value"
    }
  }
}