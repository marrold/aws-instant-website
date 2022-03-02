# We create an OAI to associate with the bucket, preventing uses from accessing the bucket directly.
resource "aws_cloudfront_origin_access_identity" "cloudfront_oai" {
  comment = "${var.fqdn} origin access identity"
}

# Create the S3 distribution.
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3_html_bucket.bucket_regional_domain_name
    origin_id   = var.fqdn

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_oai.cloudfront_access_identity_path
    }

  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.fqdn
  default_root_object = var.index_html

  aliases = concat([var.fqdn],local.reassembled_subdomains)

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.fqdn
    viewer_protocol_policy = var.viewer_protocol_policy

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type   = "origin-request"   
      include_body = false
      lambda_arn   = aws_lambda_function.lambda.qualified_arn
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.acm_cert_validation.certificate_arn
    ssl_support_method = "sni-only"
  }
}