############################
# Lambda Outputs
############################

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.main_lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.main_lambda.arn
}

output "lambda_role_arn" {
  description = "ARN of the IAM role for the Lambda function"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_role_name" {
  description = "Name of the IAM role for the Lambda function"
  value       = aws_iam_role.lambda_role.name
}

############################
# S3 Outputs
############################

output "deployment_bucket_name" {
  description = "Name of the S3 bucket for Lambda deployments"
  value       = module.lambda_deployment_bucket.s3_bucket_id
}

############################
# Network Outputs (Conditional)
############################

output "lambda_security_group_id" {
  description = "ID of the Lambda security group (if inside_vpc is true)"
  value       = var.inside_vpc ? aws_security_group.lambda_sg[0].id : null
}
