###############################################
# 1. IAM Role for Lambda Execution
###############################################

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AWS managed policy for CloudWatch logging
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

###############################################
# 2. Use existing GitHub OIDC Provider
###############################################

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

###############################################
# 3. IAM Role for GitHub Actions (OIDC)
###############################################

resource "aws_iam_role" "github_actions_oidc_role" {
  name = "project2-github-actions-oidc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            # Restrict to your GitHub repos (best security practice)
            "token.actions.githubusercontent.com:sub" = "repo:krishnatejab17/*"
          }
        }
      }
    ]
  })
}

###############################################
# 4. Least-privilege policy for CI/CD
###############################################

resource "aws_iam_policy" "lambda_cicd_policy" {
  name        = "project2-lambda-cicd-policy"
  description = "Least privilege policy for Lambda CI/CD deployments"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      # Allow upload to S3 deployment bucket
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::serverless-lambda-deploy-bucket-12345",
          "arn:aws:s3:::serverless-lambda-deploy-bucket-12345/*"
        ]
      },

      # Allow updating Lambda code (CI/CD)
      {
        Effect = "Allow",
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetFunction",
          "lambda:ListVersionsByFunction"
        ],
        Resource = "arn:aws:lambda:us-east-1:828411126532:function:hello-lambda-cicd"
      }
    ]
  })
}

###############################################
# 5. Attach CI/CD policy to GitHub Actions role
###############################################

resource "aws_iam_role_policy_attachment" "github_actions_oidc_policy_attach" {
  role       = aws_iam_role.github_actions_oidc_role.name
  policy_arn = aws_iam_policy.lambda_cicd_policy.arn
}
