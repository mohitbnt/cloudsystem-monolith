# Publish the Certificate ARN
output "tls_certificate_arn" {
  description = "The ARN of the TLS certificate"
  value = aws_acm_certificate.tls_certificate.arn
}