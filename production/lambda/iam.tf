##----------------------------------------------------------------------------- 
## Below resource will deploy IAM role in AWS environment.   
##-----------------------------------------------------------------------------
resource "aws_iam_role" "lambda_exec" {
  name               = "${local.name}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

##----------------------------------------------------------------------------- 
## IAM Policy for Lambda Logging
##-----------------------------------------------------------------------------
resource "aws_iam_policy" "lambda_logging" {
  name        = "${local.name}-logging-policy"
  description = "Policy to allow Lambda functions to write logs to CloudWatch"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

##----------------------------------------------------------------------------- 
## IAM Policy for SES Access
##-----------------------------------------------------------------------------
resource "aws_iam_policy" "lambda_ses" {
  name        = "${local.name}-ses-policy"
  description = "Policy to allow Lambda function to send emails via SES"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "arn:aws:ses:us-east-1:144817152095:identity/mauricetjmurphy@gmail.com"
      }
    ]
  })
}

##----------------------------------------------------------------------------- 
## Attach SES Policy to the IAM Role
##-----------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "attach_lambda_ses" {
  policy_arn = aws_iam_policy.lambda_ses.arn
  role       = aws_iam_role.lambda_exec.name
}

##----------------------------------------------------------------------------- 
## Attach Logging Policy to the IAM Role
##-----------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "attach_lambda_logging" {
  policy_arn = aws_iam_policy.lambda_logging.arn
  role       = aws_iam_role.lambda_exec.name
}