locals {
  
  # Build a list of the file keys
  file_keys = try(fileset(var.file_path, "**"), [])

  # Build a list of full paths to yaml files
  file_full_paths = try(flatten([

      for file in fileset(var.file_path, "**") :
        format("%s/%s", var.file_path, file)

  ]), null)

  # Merge everything into a single map
  merged_paths = zipmap(
    local.file_keys != null ? local.file_keys : [] , 
    local.file_full_paths != null ? local.file_full_paths : []
  )

}

# Create a random string to concat with the bucket name
resource "random_string" "random_id" {

  length = 16
  special = false
  upper = false
  lower = true

}

# We only want end users to access the contents of our bucket via Cloudfront, so we create a policy to enforce this.
data "aws_iam_policy_document" "iam_policy_doc" {

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront_oai.iam_arn]
    }
  }

}

# We then attach the policy to the bucket
resource "aws_s3_bucket_policy" "s3_bucket_policy" {

  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.iam_policy_doc.json

}

# Create the bucket
resource "aws_s3_bucket" "s3_bucket" {

  # Bucket names must be unique globally, so we concat a random string on the end of the FQDN
  bucket = "${var.fqdn}-${random_string.random_id.id}"
  acl    = "private"

  website {
    index_document = var.index_html
    error_document = var.error_html
  }

}

resource "aws_s3_bucket_object" "object" {
  
  for_each = local.merged_paths != null ? local.merged_paths : {}

  bucket = aws_s3_bucket.s3_bucket.id
  key    = each.key
  source = each.value
  acl    = "private"

  etag = filemd5(each.value)

}

