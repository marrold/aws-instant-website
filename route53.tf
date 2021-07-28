locals {

  # If the user hasn't explicitly supplied the route53_zone, we assume its the FQDN
  route53_zone = var.route53_zone != "" ? var.route53_zone : var.fqdn

}

data "aws_route53_zone" "route53_zone" {

  # Get the zone ID for the zone. We assume it was created using another method.
  name         = "${local.route53_zone}."

}

# Create DNS records to validate the ACM certificate. For whatever reason its attributes 
# are a list so we handle accordingly.
resource "aws_route53_record" "validation_record" {

  for_each = {
    for dvo in aws_acm_certificate.acm_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.route53_zone.zone_id

}

# We create an alias record for the cloudfront distribution. This allows us to place it at the apex 
# of the domain if required.
resource "aws_route53_record" "alias_record" {

  for_each = toset(concat([var.fqdn],local.reassembled_subdomains))

  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = each.key
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }

}