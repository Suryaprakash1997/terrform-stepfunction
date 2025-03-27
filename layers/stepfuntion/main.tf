# # Fetch current AWS account ID
# data "aws_caller_identity" "current" {}

# # IAM Role for Step Function
# resource "aws_iam_role" "step_function_role" {
#   name = "${var.organization}-${var.env}-step-function-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action    = "sts:AssumeRole"
#       Effect    = "Allow"
#       Principal = { Service = "states.amazonaws.com" }
#     }]
#   })
# }

# # IAM Policy for Step Function to Invoke Lambda
# resource "aws_iam_policy" "step_function_lambda_invoke" {
#   name        = "${var.organization}-${var.env}-step-function-lambda-invoke"
#   path        = "/"
#   description = "IAM policy for Step Function to invoke specific Lambda functions"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "lambda:InvokeFunction"
#         ]
#         Resource = [for lambda_name in var.lambda_names : 
#           "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.organization}-${var.env}-${lambda_name}"
#         ]
#       }
#     ]
#   })
# }

# # Attach Lambda Invoke Policy to Step Function Role
# resource "aws_iam_role_policy_attachment" "step_function_lambda_invoke" {
#   role       = aws_iam_role.step_function_role.name
#   policy_arn = aws_iam_policy.step_function_lambda_invoke.arn
# }

# # Read the YAML definition file
# data "local_file" "step_function_definition_yaml" {
#   filename = var.step_function_definition_path
# }

# # Convert YAML to JSON for Step Function definition
# locals {
#   step_function_definition_json = yamldecode(data.local_file.step_function_definition_yaml.content)
# }

# # Resource-based permissions for Lambda functions
# # This ensures that ONLY this specific Step Function can invoke these Lambda functions
# resource "aws_lambda_permission" "step_function_permission" {
#   for_each = toset(var.lambda_names)

#   statement_id  = "AllowExecutionFromStepFunction"
#   action        = "lambda:InvokeFunction"
#   function_name = "${var.organization}-${var.env}-${each.value}"
#   principal     = "states.amazonaws.com"
  
#   # Restrict permission to only this specific Step Function
#   source_arn = module.step_function.state_machine_arn
# }

# # AWS Step Function Module
# module "step_function" {
#   source  = "terraform-aws-modules/step-functions/aws"
#   version = "~> 1.0"

#   name     = "${var.organization}-${var.env}-step-function"
#   type     = "STANDARD"
#   role_arn = aws_iam_role.step_function_role.arn

#   definition = jsonencode(local.step_function_definition_json)

#   tags = var.tags
# }