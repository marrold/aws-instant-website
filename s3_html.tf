locals {

  # Build a list of mime types from the included defaults and the user supplied overrides
  merged_mime_types = merge(local.default_mime_types, var.mime_type_overrides)
  
  # Build a list of the file keys
  file_keys = [for fileset in try(fileset(var.file_path, "**"), [])  : fileset if fileset != ".DS_Store"]

  # Build a map of file names, full paths, and mime-types
  file_map = flatten([

      # If you get an error here it's probably because the MIME type isn't defined for the file extension. 
      # add it in mime_type_overrides.tf and submit a PR / raise an issue on Github
      for file in local.file_keys : {
        "path"      = format("%s/%s", var.file_path, file), 
        "mime_type" = local.merged_mime_types[split(".", file)[length(split(".", file)) - 1]]
      }

  ])

  # Merge everything into a single map
  merged_paths = zipmap(
    local.file_keys != null ? local.file_keys : [] , 
    local.file_map  != null ? local.file_map : []
  )

}

# Create a random string to concat with the HTML bucket name
resource "random_string" "random_id" {

  length  = 16
  special = false
  upper   = false
  lower   = true

}

# We only want end users to access the contents of our HTML bucket via Cloudfront, so we create a policy to enforce this.
data "aws_iam_policy_document" "s3_html_iam_policy_doc" {

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_html_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_oai.iam_arn]
    }
  }

}

# We then attach the policy to the HTML bucket
resource "aws_s3_bucket_policy" "s3_html_bucket_policy" {

  bucket = aws_s3_bucket.s3_html_bucket.id
  policy = data.aws_iam_policy_document.s3_html_iam_policy_doc.json

}

# Create the HTML bucket
resource "aws_s3_bucket" "s3_html_bucket" {

  # Bucket names must be unique globally, so we concat a random string on the end of the FQDN
  bucket = "${var.fqdn}-html-${random_string.random_id.id}"

}


# Configure the website config for the HTML bucket
resource "aws_s3_bucket_website_configuration" "s3_html_bucket_website_configuration" {
  
  bucket = aws_s3_bucket.s3_html_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

# Create an ACL for the HTML bucket
resource "aws_s3_bucket_acl" "s3_html_bucket_acl" {
  bucket = aws_s3_bucket.s3_html_bucket.id
  acl    = "private"
}

# Upload the HTML files to the HTML bucket
resource "aws_s3_object" "object" {
  
  for_each     = local.merged_paths != null ? local.merged_paths : {}

  bucket       = aws_s3_bucket.s3_html_bucket.id
  key          = each.key
  source       = each.value.path
  acl          = "private"
  content_type = each.value.mime_type
  etag         = filemd5(each.value.path)

}
