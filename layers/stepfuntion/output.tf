# ######################
# # Step Function Outputs
# ######################

# output "step_function_name" {
#   description = "The name of the Step Function"
#   value       = module.step_function.state_machine_name
# }

# output "step_function_id" {
#   description = "The ID of the Step Function"
#   value       = module.step_function.state_machine_id
# }

# output "step_function_arn" {
#   description = "The ARN of the Step Function"
#   value       = module.step_function.state_machine_arn
# }


# ######################
# # IAM Role Outputs
# ######################

# output "step_function_role_name" {
#   description = "The name of the IAM role used by the Step Function"
#   value       = aws_iam_role.step_function_role.name
# }

# output "step_function_role_id" {
#   description = "The ID of the IAM role used by the Step Function"
#   value       = aws_iam_role.step_function_role.id
# }

# output "step_function_role_arn" {
#   description = "The ARN of the IAM role used by the Step Function"
#   value       = aws_iam_role.step_function_role.arn
# }