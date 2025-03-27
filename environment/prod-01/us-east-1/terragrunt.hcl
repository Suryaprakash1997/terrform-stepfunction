remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "rgb-stage-01-atlantis-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "rgb-stage-01-atlantis-terraform-locks"
    s3_bucket_tags = {
      ManagedBy     = "Terraform"
      ProvisionedBy = "Surya"
      Purpose       = "store terraform state files"
    }
    dynamodb_table_tags = {
      ManagedBy     = "Terraform"
      ProvisionedBy = "Surya"
      Purpose       = "store terraform lock file"
    }
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.31.0"
    }
  }
}

EOF
}
