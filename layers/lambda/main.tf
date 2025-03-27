############################
# Lambda Package
############################

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/artifacts/initial_python.py"
  output_path = "${path.module}/lambda.zip"
}

############################
# IAM Resources
############################

# IAM Role for Lambda - Restricted to only be assumed by this specific Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.organization}-${var.env}-${var.index}-${var.service}-role"

  assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [{
    Action    = "sts:AssumeRole"
    Effect    = "Allow"
    Principal = { Service = "lambda.amazonaws.com" }
    Condition = {
      ArnLike = {
        "aws:SourceArn": "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.organization}-${var.env}-${var.index}-${var.service}-lambda"
      }
    }
  }]
})

  tags = var.tags
}

# Default policy for Secrets Manager and Parameter Store access
resource "aws_iam_policy" "default_permissions" {
  name        = "${var.organization}-${var.env}-${var.index}-${var.service}-default-policy"
  description = "Default permissions for ${var.organization}-${var.env}-${var.index}-${var.service} Lambda function"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:${var.organization}/${var.env}/${var.index}/lambda/${var.service}*"
      },
      {
        Sid    = "AllowAccessToParameterStore"
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:${var.region}:${var.account_id}:parameter/${var.organization}/${var.env}/${var.index}/lambda/${var.service}/*"
        ]
      }
    ]
  })
  
  tags = var.tags
}

# Attach default permissions policy
resource "aws_iam_role_policy_attachment" "default_permissions" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.default_permissions.arn
}

# Attach AWS-Managed Lambda Policy for Logging
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach additional policies if provided
resource "aws_iam_role_policy_attachment" "additional_policies" {
  count      = length(var.existing_policies)
  role       = aws_iam_role.lambda_role.name
  policy_arn = var.existing_policies[count.index]
}

# Create custom policy if JSON provided
resource "aws_iam_policy" "custom_policy" {
  count       = var.custom_policy != "" ? 1 : 0
  name        = "${var.organization}-${var.env}-${var.index}-${var.service}-custom-policy"
  description = "Custom policy for ${var.organization}-${var.env}-${var.index}-${var.service} Lambda function"
  policy      = var.custom_policy
  
  tags = var.tags
}

# Attach custom policy if created
resource "aws_iam_role_policy_attachment" "custom_policy_attachment" {
  count      = var.custom_policy != "" ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.custom_policy[0].arn
}

# VPC Execution Role if VPC is enabled
resource "aws_iam_role_policy_attachment" "vpc_execution" {
  count      = var.inside_vpc ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


# resource "time_sleep" "wait_for_iam_role_propagation" {
#   depends_on = [
#     aws_iam_role.lambda_role,
#     aws_iam_role_policy_attachment.lambda_basic_execution,
#     aws_iam_role_policy_attachment.default_permissions
#   ]
#   create_duration = "10s"
# }
############################
# S3 Resources
############################

module "lambda_deployment_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1.0"
  
  bucket        = "${var.organization}-${var.env}-${var.index}-${replace(var.service, "_", "-")}-s3"
  force_destroy = true
  
  # S3 bucket-level settings
  versioning = {
    enabled = true
  }
  
  # Security settings
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.organization}-${var.env}-${var.index}-${var.service}-deployments"
    }
  )
}

############################
# Network Resources (Conditional)
############################

# Security Group for Lambda (if VPC is enabled)
resource "aws_security_group" "lambda_sg" {
  count       = var.inside_vpc ? 1 : 0
  name        = "${var.organization}-${var.env}-${var.index}-${var.service}-sg"
  description = "Security group for Lambda"
  vpc_id      = var.vpc_id
  
  # No default egress rules - they'll be added conditionally below
  
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.organization}-${var.env}-${var.index}-${var.service}-sg"
    }
  )
}

# Conditional egress rule based on required_outbound_cidrs variable
resource "aws_security_group_rule" "egress_rules" {
  count             = var.inside_vpc && length(var.required_outbound_cidrs) > 0 ? length(var.required_outbound_cidrs) : 0
  security_group_id = aws_security_group.lambda_sg[0].id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.required_outbound_cidrs[count.index]]
  description       = "Outbound access to ${var.required_outbound_cidrs[count.index]}"
}

############################
# Lambda Function
############################

# Main Lambda Function with conditional VPC config
resource "aws_lambda_function" "main_lambda" {
  function_name = "${var.organization}-${var.env}-${var.index}-${var.service}-lambda"
  role          = aws_iam_role.lambda_role.arn
  runtime       = var.runtime
  handler       = var.handler
  memory_size   = var.memory_size
  timeout       = var.timeout
   ephemeral_storage {
    size = var.ephemeral_storage_size
  }

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # VPC configuration if VPC is enabled
  dynamic "vpc_config" {
    for_each = var.inside_vpc ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = [aws_security_group.lambda_sg[0].id]
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [filename, source_code_hash, environment, s3_key, s3_object_version]
  }

  depends_on = [ aws_iam_role_policy_attachment.lambda_basic_execution ]
  
  tags = var.tags
}

############################
# Update IAM Role Trust Policy with Condition
############################

# Update IAM Role trust policy with the Lambda ARN condition
resource "aws_iam_role_policy" "lambda_trust_policy_condition" {
  name   = "lambda-trust-policy-condition"
  role   = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Condition = {
        ArnLike = {
          "aws:SourceArn": "arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.main_lambda.function_name}"
        }
      }
    }]
  })

  depends_on = [aws_lambda_function.main_lambda]
}

############################
# Scheduler Integration (Conditional)
############################

# EventBridge Rule (if scheduler is enabled)
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  count               = var.create_scheduler ? 1 : 0
  name                = "${var.organization}-${var.env}-${var.index}-${var.service}-schedule"
  schedule_expression = var.schedule_expression
  
  tags = var.tags
}

# EventBridge Target (if scheduler is enabled)
resource "aws_cloudwatch_event_target" "lambda_target" {
  count = var.create_scheduler ? 1 : 0
  rule  = aws_cloudwatch_event_rule.lambda_schedule[0].name
  arn   = aws_lambda_function.main_lambda.arn
}

# EventBridge Lambda Permission (if scheduler is enabled)
resource "aws_lambda_permission" "eventbridge_permission" {
  count         = var.create_scheduler ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule[0].arn
}