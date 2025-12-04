terraform {
  backend "s3" {
    bucket         = "serverless-lambda-deploy-bucket-12345"
    key            = "prod/terraform.tfstate" #location inside bucket
    region         = "us-east-1"
    encrypt        = true
  }
}
