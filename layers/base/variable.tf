################################################################################
# General
################################################################################
variable "organization" {
  description = "name of organization"
  type        = string
  default     = ""
}
variable "service" {
  description = "service name"
  type        = string
  default     = ""
}
variable "env" {
  description = "environment"
  type        = string
  default     = ""
}
variable "region" {
  description = "aws region"
  type        = string
  default     = ""
}
variable "index" {
  description = "index"
  type        = string
  default     = ""
}
################################################################################
# VPC
################################################################################

variable "vpc_cidr" {
  description = "(Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`"
  type        = string
  default     = ""
}
variable "number_of_azs" {
  description = "Number of availability zones names or ids in the region"
  type        = number
  default     = 3
}

variable "number_of_private_subnets" {
  description = "Number of private subnets needed"
  type        = number
  default     = 3
}

variable "number_of_public_subnets" {
  description = "Number of public subnets needed"
  type        = number
  default     = 3
}

variable "tunnel_instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = ""
}

variable "tunnel_key" {
  description = "The cloudflare tunnel key"
  type        = string
  default     = ""
}

variable "tunnel_ami" {
  description = "The ami of tunnel ec2"
  type        = string
  default     = ""
}
variable "ebs_throughput" {
  description = "Throughput in MiB for EBS Vol"
  type        = number
  default     = 125
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}