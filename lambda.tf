/**
 * Create a random string to concat with the lambda name
*/
resource "random_string" "random_lambda_id" {

  length  = 16
  special = false
  upper   = false
  lower   = true

}


/**
 * Lambdas are uploaded to via zip files, so we create a zip out of a given directory.
 * In the future, we may want to source our code from an s3 bucket instead of a local zip.
 */
data "archive_file" "zip_file_for_lambda" {
  type        = "zip"
  output_path = "./cf_rewrite_index.zip"

  dynamic "source" {
    for_each = distinct(flatten([
      for blob in ["index.js", "node_modules/**", "yarn.lock", "package.json"]:
      fileset("${path.module}/cf_index_rewrite/", blob)
    ]))
    content {
      content = try(
        file("${path.module}/cf_index_rewrite/${source.value}"),
        filebase64("${path.module}/cf_index_rewrite/${source.value}"),
      )
      filename = source.value
    }
  }
}

/**
 * Upload the build artifact zip file to S3.
 *
 * Doing this makes the plans more resiliant, where it won't always
 * appear that the function needs to be updated
 */
resource "aws_s3_object" "artifact" {

  # edge lambdas need to live in us-east-1
  provider = aws.us-east-1

  bucket = aws_s3_bucket.s3_lambda_bucket.id
  key    = "cf_rewrite_index.zip"
  source = data.archive_file.zip_file_for_lambda.output_path
  etag   = data.archive_file.zip_file_for_lambda.output_md5
}


/**
 * Create the Lambda function. Each new apply will publish a new version.
 */
resource "aws_lambda_function" "lambda" {

  # edge lambdas need to live in us-east-1
  provider = aws.us-east-1

  function_name = "cf_rewrite_index_${random_string.random_lambda_id.id}"
  description   = "Cloudfront index rewrite"

  # Find the file from S3
  s3_bucket         = aws_s3_bucket.s3_lambda_bucket.id
  s3_key            = aws_s3_object.artifact.id
  s3_object_version = aws_s3_object.artifact.version_id
  source_code_hash  = filebase64sha256(data.archive_file.zip_file_for_lambda.output_path)

  publish = true
  handler = "index.handler"
  runtime = "nodejs14.x"
  role    = aws_iam_role.lambda_at_edge.arn

  lifecycle {
    ignore_changes = [
      last_modified,
    ]
  }
}

/**
 * Policy to allow AWS to access this lambda function.
 */
data "aws_iam_policy_document" "assume_role_policy_doc" {

  statement {
    sid    = "AllowAwsToAssumeRole"
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }
  }
}

/**
 * Make a role that AWS services can assume that gives them access to invoke our function.
 * This policy also has permissions to write logs to CloudWatch.
 */
resource "aws_iam_role" "lambda_at_edge" {

  # edge lambdas need to live in us-east-1
  provider = aws.us-east-1

  name               = "cf_rewrite_index_role_${random_string.random_lambda_id.id}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_doc.json
}

/**
 * Allow lambda to write logs.
 */
data "aws_iam_policy_document" "lambda_logs_policy_doc" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",

      # Lambda@Edge logs are logged into Log Groups in the region of the edge location
      # that executes the code. Because of this, we need to allow the lambda role to create
      # Log Groups in other regions
      "logs:CreateLogGroup",
    ]
  }
}

/**
 * Attach the policy giving log write access to the IAM Role
 */
resource "aws_iam_role_policy" "logs_role_policy" {

  # edge lambdas need to live in us-east-1
  provider = aws.us-east-1

  name   = "cf_rewrite_index_at_edge"
  role   = aws_iam_role.lambda_at_edge.id
  policy = data.aws_iam_policy_document.lambda_logs_policy_doc.json
}

/**
 * Creates a Cloudwatch log group for this function to log to.
 * With lambda@edge, only test runs will log to this group. All
 * logs in production will be logged to a log group in the region
 * of the CloudFront edge location handling the request.
 */
resource "aws_cloudwatch_log_group" "log_group" {

  name = "/aws/lambda/cf_rewrite_index_${random_string.random_lambda_id.id}"
}
