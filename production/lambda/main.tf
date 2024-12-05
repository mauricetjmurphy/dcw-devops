provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket  = "gemtech-remotestate-prod"
    key     = "dcw/lambda/mail-service/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    profile = "default"
  }
}

locals {
  environment = "prod"
  name        = "dcw-mail-service"
  description = "Documated mail service"
}

# Lambda Function Module
module "lambda" {
  source               = "git::https://github.com/mauricetjmurphy/terraform-modules.git//lambda/lambda-api"
  lambda_function_name = local.name
  environment          = local.environment
  description          = local.description
  label_order          = ["name", "environment"]
  enable               = true
  lambda_timeout       = 60
  handler              = "app.main.handler"
  runtime              = "python3.10"
  lambda_exec_role_arn = aws_iam_role.lambda_exec.arn

  lambda_env_vars = {
    REGION = "us-east-1"
  }
}

