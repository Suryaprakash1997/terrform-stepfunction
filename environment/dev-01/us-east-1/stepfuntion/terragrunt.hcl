# terraform {
#   source = "../../../layer/stepfuntion"
# }

# include "root" {
#   path = find_in_parent_folders()
# }

# include "env" {
#   path           = find_in_parent_folders("env.hcl")
#   expose         = true
#   merge_strategy = "no_merge"
# }

# dependency "lambda" {
#   config_path = "../lambda"
#   mock_outputs = {
#     alb_lambda_function_arn   = "arn:aws:lambda:ap-south-1:000000000000:function:mock-lambda"
#   }
# }

# inputs = {
#   project         = include.env.locals.project
#   organization    = include.env.locals.organization
#   env             = include.env.locals.env
#   region          = include.env.locals.region
#   index           = include.env.locals.index
  
#   step_function_definition_json = jsonencode({
#     "Comment": "Example Step Function",
#     "StartAt": "Wait",
#     "States": {
#       "Wait": {
#         "Type": "Wait",
#         "Seconds": 5,
#         "Next": "InvokeLambda"
#       },
#       "InvokeLambda": {
#         "Type": "Task",
#         "Resource": "${dependency.lambda.outputs.alb_lambda_function_arn}",
#         "End": true
#       }
#     }
#   })
  
#   tags = include.env.locals.tags
# }