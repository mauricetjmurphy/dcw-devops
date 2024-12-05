provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket  = "gemtech-remotestate-prod"
    key     = "dcw/rest-api-gateway/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    profile = "default"
  }
}

locals {
  region           = "us-east-1" 
  stage_name       = "prod"
  api_name         = "dcw-rest-api"
  hosted_zone_name = "documated.com"
}

module "api_gateway" {
  source          = "git::https://github.com/mauricetjmurphy/terraform-modules.git//api-gateway/api-gateway-rest"
  api_name        = local.api_name
  region          = local.region
  stage_name      = local.stage_name
}

# Base Path Mapping
resource "aws_api_gateway_base_path_mapping" "custom_domain_mapping" {
  domain_name = aws_api_gateway_domain_name.custom_domain.domain_name
  stage_name  = local.stage_name
  api_id      = module.api_gateway.id
}

# /mail/{proxy+} Route for Mail Service
resource "aws_api_gateway_resource" "mail" {
  rest_api_id = module.api_gateway.id
  parent_id   = module.api_gateway.root_resource_id
  path_part   = "mail"
}

resource "aws_api_gateway_resource" "mail_proxy" {
  rest_api_id = module.api_gateway.id
  parent_id   = aws_api_gateway_resource.mail.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "mail_proxy_method" {
  rest_api_id   = module.api_gateway.id
  resource_id   = aws_api_gateway_resource.mail_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "mail_proxy_integration" {
  rest_api_id             = module.api_gateway.id
  resource_id             = aws_api_gateway_resource.mail_proxy.id
  http_method             = aws_api_gateway_method.mail_proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.mail_service.arn}/invocations"
}

resource "aws_api_gateway_stage" "custom_stage" {
  rest_api_id = module.api_gateway.id
  stage_name  = local.stage_name
  deployment_id = aws_api_gateway_deployment.deployment.id
}

# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.mail_proxy_integration,
  ]
  rest_api_id = module.api_gateway.id
  description = "Deployment triggered at ${timestamp()}"
}

resource "aws_lambda_permission" "mail_api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGatewayMail"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:us-east-1:144817152095:function:dcw-mail-service"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.execution_arn}/*/mail/*"
}