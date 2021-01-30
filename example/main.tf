module "website" {

    source = "github.com/marrold/aws-instant-website?ref=v0.1"

    providers = {
      aws     = aws
      aws.us-east-1 = aws.us-east-1
    }

    fqdn = "www.example.org"

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
}