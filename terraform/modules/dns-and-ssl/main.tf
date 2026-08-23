# Cloudflare Terraform Provider
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.23.0"
    }
  }
}

# Request the ACM Certificate
resource "aws_acm_certificate" "tls_certificate" {
  domain_name       = var.domain_name
  subject_alternative_names = [
    "*.${var.domain_name}"
  ]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-tls-certificate"
  })
}

# Create the Validation DNS Records in Cloudflare
resource "cloudflare_dns_record" "acm_validation" {
  for_each = {
    "validation" = var.domain_name
  }

  zone_id = var.cloudflare_zone_id

  # one() extracts the single string out of the filtered tuple list,
  # fulfilling Cloudflare's string requirements perfectly.
  name = one([
    for dvo in aws_acm_certificate.tls_certificate.domain_validation_options : dvo.resource_record_name
    if dvo.domain_name == each.value
  ])

  content = one([
    for dvo in aws_acm_certificate.tls_certificate.domain_validation_options : dvo.resource_record_value
    if dvo.domain_name == each.value
  ])

  type = one([
    for dvo in aws_acm_certificate.tls_certificate.domain_validation_options : dvo.resource_record_type
    if dvo.domain_name == each.value
  ])

  ttl     = 1
  proxied = false
}

# Complete the Validation Loop
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.tls_certificate.arn
  validation_record_fqdns = [for record in cloudflare_dns_record.acm_validation : record.name]
}

# Create DNS record for the domain pointing to the ALB
resource "cloudflare_dns_record" "alb_dns_record" {
  for_each = toset(local.website_dns_records)

  zone_id = var.cloudflare_zone_id
  name    = each.value
  ttl     = 300
  type    = "CNAME"
  content = var.alb_dns_name
  proxied = false
}