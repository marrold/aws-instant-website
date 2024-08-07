# aws-instant-website

aws-instant-website is a [terraform](https://www.terraform.io/) configuration to build a public static website in AWS S3, with Cloudfront in front allowing you to use a custom domain + DNS with TLS. A Lambda@Edge function deals with re-writing paths so a URI that doesn't end with a filename automatically requests index.html

It's assumed you're already (partially) experienced with AWS and Terraform and just want a static website without making 3000 clicks in the console. Or spending 2 evenings making this module.

It's also assumed that you're already managing DNS with Route53 and the zone is already setup. If you're using another DNS provider and would like to use this module, raise an issue and I'll see what I can do.

The module _can_ upload files from a local directory of your choice to the S3 bucket but it's probably inefficent vs uploading via another method.  
                
## Disclaimer

AWS can get expensive. Possibly more expensive than just hosting a static website on a cheap VPS or hosting provider. Set sensible budget limits / alarms and read the AWS docs to understand the pricing.

This module has been tested with Terraform `0.15.5`

## Example

An example is included in the `examples` directory in this repository.

It's assumed that you already have Terraform installed and configured, and your AWS profiles and credentials setup.

### Configuration

- Copy `provider.tf_EXAMPLE` to `provider.tf`

- Edit the profiles and regions as required.

### A note on mime types
If you don't explicitly define the mime type for each file uploaded to S3 with Terraform it will default to `binary/octet-stream` which results in your browser downloading the file rather than rendering it. To resolve this issue, the mime type is inferred from the file extension. This should work in most instances but there might be the odd edge case when it fails.  It's possible to override the defined the default mime types (See below). If you an encounter an issue please raise an issue so I can take a look.

### Usage

In your main terraform file you can define the FQDN of your website and the `file_path` to a directory of files you want uploading to s3.

Your .tf file should look something like this: 
  
    module "website" {
    
        source = "github.com/marrold/aws-instant-website?ref=v0.22"
    
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
  
 Once you've configured the module and the yaml files you can run the usual:
```
terraform init
terraform apply
```

##### Options

-  **fqdn**: This is the _full_ domain you want your website to  be accessed via. [Mandatory]

- **subdomains**: subdomains of the FQDN, e.g www

-  **file_path**: The path to a directory of files you want uploaded to s3. If this value is not defined it's assumed you'll upload files using another method.

-  **route53_zone**: The top level domain that's managed in AWS Route53. If it's commented out or not supplied, it's assumed the fqdn is also associated with a route53 zone. 

- **index_html**: The file name for the index page. Defaults to index.html

- **error_html**: Filename for the error page. Defaults to error.html

- **viewer_protocol_policy**: Specify which protocol viewers can access the website via. One of allow-all, https-only, or redirect-to-https. Defaults to redirect-to-https.

- **price_class**:  Sets the price class, e.g which regions content is served from. More regions = more expensive. Defaults to PriceClass_100.

	    PriceClass_100: Use Only U.S., Canada and Europe
	    PriceClass_200: Use U.S., Canada, Europe, Asia, Middle East and Africa
	    PriceClass_All: Use All Edge Locations (Best Performance)
	    
- **mime_type_overrides**: A map of file extensions and their mime-types, to override those set by the module. 


## Caveats

- **Deleting Lambda@Edge functions and replicas**: When you destroy the resources you might get a warning that the lambda function couldn't be deleted. This is because it can't be deleted until the replicas are destroyed on the AWS side. You may need to re-run the destory task a few hours later [AWS Docs](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-delete-replicas.html)
## Acknowledgements

- cf_index_rewrite: [Ronnie Eichler](https://aws.amazon.com/blogs/compute/implementing-default-directory-indexes-in-amazon-s3-backed-amazon-cloudfront-origins-using-lambdaedge/)
- lambda@edge: [transcend-io](https://github.com/transcend-io/terraform-aws-lambda-at-edge)
## License

This project is licensed under the terms of the _MIT license_

