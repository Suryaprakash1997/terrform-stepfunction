variable "organization" {
  description = "name of organization"
  type        = string
  default     = "brc"
}

variable "product" {
  description = "product name"
  type        = string
  default     = ""
}

variable "revision" {
  description = "product version"
  type        = string
  default     = ""
}

variable "env" {
  description = "product environment"
  type        = string
  default     = "infra"
}

variable "region" {
  description = "aws region"
  type        = string
  default     = "us-east-1"
}

variable "index" {
  description = "index"
  type        = string
  default     = "01"
}

variable "service" {
  description = "service"
  type        = string
  default     = "atlantis"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}


variable "vpc_id" {
  description = "ID of existing VPC"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
  default     = [""]
}

variable "public_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
  default     = [""]
}