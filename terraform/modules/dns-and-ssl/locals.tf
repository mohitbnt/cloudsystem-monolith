locals {
  website_dns_records = [var.domain_name, "www.${var.domain_name}"]
}