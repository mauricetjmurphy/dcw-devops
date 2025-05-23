data "aws_acm_certificate" "certificate" {
  domain   = local.root_domain
  statuses = ["ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "hosted_zone" {
  name         = local.root_domain
  private_zone = false
}