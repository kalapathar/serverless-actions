data "aws_region" "current" {
}

resource "aws_lambda_function" "lambda" {
  description = var.description
  dynamic "environment" {
    for_each = length(var.environment) < 1 ? [] : [var.environment]
    content {
      variables = environment.value.variables
    }
  }
  filename                       = var.s3_bucket == "" ? var.filename : null
  function_name                  = var.function_name
  handler                        = var.handler
  memory_size                    = var.memory_size
  publish                        = var.publish
  reserved_concurrent_executions = var.reserved_concurrent_executions
  role                           = aws_iam_role.lambda.arn
  runtime                        = var.runtime
  s3_bucket                      = var.filename == "" ? var.s3_bucket : null
  s3_key                         = var.filename == "" ? var.s3_key : null
  s3_object_version              = var.filename == "" ? var.s3_object_version : null
  source_code_hash               = var.source_code_hash
  tags                           = var.tags
  timeout                        = var.timeout

  dynamic "vpc_config" {
    for_each = length(var.vpc_config) < 1 ? [] : [var.vpc_config]
    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnet_ids         = vpc_config.value.subnet_ids
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.function_name}-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_bucket_access" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "vpc_attachment" {
  count = length(var.vpc_config) < 1 ? 0 : 1
  role  = aws_iam_role.lambda.name

  // see https://docs.aws.amazon.com/lambda/latest/dg/vpc.html
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
