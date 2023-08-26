# Create the lambda bucket
resource "aws_s3_bucket" "s3_lambda_bucket" {

  # edge lambdas need to live in us-east-1
  provider = aws.us-east-1

  # Bucket names must be unique globally, so we concat a random string on the end of the FQDN
  bucket = "${var.fqdn}-lambda-${random_string.random_id.id}"

}

# Enable versioning for the lambda bucket
resource "aws_s3_bucket_versioning" "s3_lambda_bucket_versioning" {

  # edge lambdas need to live in us-east-1
  provider = aws.us-east-1

  bucket = aws_s3_bucket.s3_lambda_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
