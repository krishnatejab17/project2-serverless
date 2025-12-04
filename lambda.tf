resource "aws_lambda_function" "hello" {
  function_name = "hello-lambda-cicd"
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = var.s3_key
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_role.arn
}
