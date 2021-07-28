# Create a cert for the cloudfront distribution
resource "aws_acm_certificate" "acm_cert" {

  # ACM certs need to live in us-east-1, for reasons
  provider = aws.us-east-1

  domain_name       = var.fqdn
  subject_alternative_names = local.reassembled_subdomains
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

}

# Validate the cert we just created.
resource "aws_acm_certificate_validation" "acm_cert_validation" {

  # ACM certs need to live in us-east-1, for reasons
  provider = aws.us-east-1

  certificate_arn         = aws_acm_certificate.acm_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_record : record.fqdn]

}