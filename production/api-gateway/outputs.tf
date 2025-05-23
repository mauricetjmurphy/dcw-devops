# Output the API Gateway URL for the root stage
output "api_gateway_url" {
  description = "The base URL for the API Gateway"
  value       = "https://${module.api_gateway.id}.execute-api.${local.region}.amazonaws.com/${local.stage_name}"
}

# Output for the deployment stage name
output "deployment_stage_name" {
  description = "The stage name for the deployed API (e.g., prod)"
  value       = local.stage_name
}

# Output the /mail/{proxy+} Lambda function ARN
output "mail_lambda_function_arn" {
  description = "The ARN of the mail Lambda function"
  value       = aws_lambda_permission.mail_api_gateway_permission.function_name
}

# Output for API Gateway Execution ARN for policy references
output "api_gateway_execution_arn" {
  description = "The execution ARN for the API Gateway, useful for IAM permissions"
  value       = module.api_gateway.execution_arn
}


