Note: This is borked beyond belief so don't use it yet...

# aws-instant-website

aws-instant-website is a [terraform](https://www.terraform.io/) configuration to build a public static website in AWS S3, with Cloudfront in front allowing you to use a custom domain + DNS with TLS.

It's assumed you're already (partially) experienced with AWS and Terraform and just want a static website without making 3000 clicks in the console. Or spending 2 evenings making this module.

It's also assumed that you're already managing DNS with Route53 and the zone is already setup. If you're using another DNS provider and would like to use this module, raise an issue and I'll see what I can do.

The module _can_ upload files from a local directory of your choice to the S3 bucket but it's probably inefficent vs uploading via another method.  
                
## Disclaimer

AWS can get expensive. Possibly more expensive than just hosting a static website on a cheap VPS or hosting provider. Set sensible budget limits / alarms and read the AWS docs to understand the pricing.

This module has been tested with Terraform `0.14.4`

## Example

An example is included in the `examples` directory in this repository.

It's assumed that you already have Terraform installed and configured, and your AWS profiles and credentials setup.

### Configuration

- Copy `provider.tf_EXAMPLE` to `provider.tf`

- Edit the profiles and regions as required.

### Usage

In your main terraform file you can define the FQDN of your website and the `file_path` to a directory of files you want uploading to s3.

Your .tf file should look something like this: 
  
    module "website" {
    
        source = "./module"
    
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
  
 Once you've configured the module and the yaml files you can run the usual:
```
terraform init
terraform apply
```

##### Options

-  **fqdn**: This is the _full_ domain you want your website to  be accessed via. [Mandatory]

-  **file_path**: The path to a directory of files you want uploaded to s3. If this value is not defined it's assumed you'll upload files using another method.

-  **route53_zone**: The top level domain that's managed in AWS Route53. If it's commented out or not supplied, it's assumed the fqdn is also associated with a route53 zone. 

- **index_html**: The file name for the index page. Defaults to index.html

- **error_html**: Filename for the error page. Defaults to error.html

- **viewer_protocol_policy**: Specify which protocol viewers can access the website via. One of allow-all, https-only, or redirect-to-https. Defaults to redirect-to-https.

- **price_class**:  # Sets the price class, e.g which regions content is served from. More regions = more expensive. Defaults to PriceClass_100.

	    PriceClass_100: Use Only U.S., Canada and Europe
	    PriceClass_200: Use U.S., Canada, Europe, Asia, Middle East and Africa
	    PriceClass_All: Use All Edge Locations (Best Performance)


## License

This project is licensed under the terms of the _MIT license_
