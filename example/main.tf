module "website" {

    source = "github.com/marrold/aws-instant-website?ref=v0.18"

    providers = {
      aws     = aws
      aws.us-east-1 = aws.us-east-1
    }

    fqdn = "example.org"

    # Specify any desired subdomains that should serve the same content. Defaults to None.
    subdomains = ["www"]

    # Path to HTML. If this value is not defined it's assumed you'll upload files using another method.
    file_path = "html/"

    # The top level domain used for the zone in route53. If left unpopulated, it's assumed to be the same as the domain defined in FQDN.
    # route53_zone = "example.org"

    # Filename for the index page. Defaults to index.html
    # index_html = "index.html"

    # Filename for the error page. Defaults to error.html
    # error_html = "error.html"

    # Specify which protocol viewers can access the website via. One of allow-all, https-only, or redirect-to-https.
    # Defaults to redirect-to-https.
    # viewer_protocol_policy = "https-only"

    # Sets the price class, e.g which regions content is served from. More regions = more expensive. Defaults to PriceClass_100.
    # PriceClass_100: Use Only U.S., Canada and Europe
    # PriceClass_200: Use U.S., Canada, Europe, Asia, Middle East and Africa
    # PriceClass_All: Use All Edge Locations (Best Performance)
    # price_class = "PriceClass_100"

    # Due to the way Terraform / S3 works we must define the correct mime-type when the file is uploaded. We infer this from a map of
    # mime-types in the module (mime-types.tf). If the mime-type for your file extension is missing or wrong, you can override it by 
    # supplying a map of overrides here. An example is included in mime_type_overrides.tf
    # mime_type_overrides = local.mime_type_overrides
}