provider "aws" {
  region = local.region
}

terraform {
  backend "s3" {
    bucket  = "gemtech-remotestate-prod"
    key     = "dcw/cloudfront/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    profile = "default"
  }
}

locals {
  region       = "us-east-1"
  name         = "dcw"
  environment  = "prod"
  domain_name  = "documated.com"
  root_domain  = "documated.com"
  bucket_name  = "${local.name}-bucket-cdn"
}

# Create the S3 bucket resource
resource "aws_s3_bucket" "cdn_bucket" {
  bucket = "${local.environment}-${local.bucket_name}"
}

# Create the S3 bucket policy
resource "aws_s3_bucket_policy" "cdn_bucket_policy" {
  bucket = aws_s3_bucket.cdn_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

# Create the CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "cloudfront" {
  comment = "CloudFront Origin Access Identity for ${local.name}-${local.environment}"
}

# Define the IAM policy for S3 bucket access
data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid     = "PolicyForCloudFrontPrivateContent"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.cloudfront.id}"
      ]
    }

    resources = ["${aws_s3_bucket.cdn_bucket.arn}/*"]
  }
}

# Create the CloudFront distribution module
module "cdn" {
  source                 = "git::ssh://git@github.com/mauricetjmurphy/gemtech-terraform-modules.git//cloudfront"
  name                   = local.name
  environment            = local.environment
  enabled_bucket         = true
  compress               = false
  aliases                = [local.domain_name]
  bucket_name            = "${local.environment}-${local.bucket_name}"
  viewer_protocol_policy = "redirect-to-https"
  allowed_methods        = ["GET", "HEAD"]
  acm_certificate_arn    = data.aws_acm_certificate.certificate.arn
  origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront.cloudfront_access_identity_path
}

# Create the Route53 A record for the domain
resource "aws_route53_record" "root_domain" {
  zone_id         = data.aws_route53_zone.hosted_zone.id
  name            = ""
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = module.cdn.domain_name
    zone_id                = module.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
