# Route 53 Record for Custom Domain
resource "aws_route53_record" "custom_domain_dns" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api.${local.hosted_zone_name}"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.custom_domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.custom_domain.cloudfront_zone_id
    evaluate_target_health = false
  }
}

# Create Custom Domain Name in API Gateway
resource "aws_api_gateway_domain_name" "custom_domain" {
  domain_name    = "api.${local.hosted_zone_name}"
  certificate_arn = data.aws_acm_certificate.custom_domain_cert.arn
}
