############################
# General Variables
############################

variable "organization" {
  description = "Organization name for resource naming"
  type        = string
  default     = "brc"

}

variable "env" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "index" {
  description = "Index for resource naming"
  type        = string
}

variable "service" {
  description = "Service name for resource naming"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "account_id" {
  description = "The AWS account ID where resources will be deployed"
  type        = string
}

variable "region" {
  description = "The AWS region where resources will be deployed"
  type        = string
}

############################
# Lambda Variables
############################

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.9"
}

variable "handler" {
  description = "Lambda handler function"
  type        = string
  default     = "python.lambda_handler"
}

variable "memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 600
}

variable "ephemeral_storage_size" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 512
}

variable "existing_policies" {
  description = "List of additional IAM policy ARNs to attach to the Lambda role"
  type        = list(string)
  default     = []
}

variable "custom_policy" {
  description = "Custom IAM policy JSON to attach to the Lambda role"
  type        = string
  default     = ""
}

############################
# Network Variables
############################

variable "inside_vpc" {
  description = "Whether to deploy Lambda inside a VPC"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID for Lambda and ALB (if inside_vpc or create_alb is true)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of private subnet IDs for Lambda VPC config and ALB"
  type        = list(string)
  default     = []
}

variable "required_outbound_cidrs" {
  description = "List of CIDR blocks that Lambda needs outbound access to"
  type        = list(string)
  default     = []
}


############################
# Scheduler Variables
############################

variable "create_scheduler" {
  description = "Whether to create a CloudWatch Events rule for scheduled Lambda invocation"
  type        = bool
  default     = false
}

variable "schedule_expression" {
  description = "CloudWatch Events schedule expression for Lambda invocation, Used 'cron(0 0 1 1 ? 3000)' to effectively disable/never run"
  type        = string
  default     = "cron(0 0 1 1 ? 3000)" // run never
}
