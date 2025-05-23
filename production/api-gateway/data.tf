data "aws_route53_zone" "main" {
  name         = local.hosted_zone_name  
  private_zone = false           
}

data "aws_acm_certificate" "custom_domain_cert" {
  domain   = local.hosted_zone_name
  statuses = ["ISSUED"]
  types    = ["AMAZON_ISSUED"]
}

# Data block to fetch the ARN for the Mail service Lambda
data "aws_lambda_function" "mail_service" {
  function_name = "dcw-mail-service"
}

