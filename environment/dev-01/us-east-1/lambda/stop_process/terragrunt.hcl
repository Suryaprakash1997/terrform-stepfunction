terraform {
  source = "../../../../../layers/lambda"
  
  before_hook "before_destroy" {
    commands = ["destroy"]
    execute  = ["echo", "Ensuring Lambda is destroyed before VPC"]
  }
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

# Updated dependency block to specifically reference shared private subnets
dependency "mm_primary_vpc" {
  config_path = "../../base"
  mock_outputs = {
    mm_primary_vpc_id = "mock-vpc-id"
    mm_primary_vpc_cidr_block = "10.0.0.0/16"
    shared_private_subnet_id = [
      "mock-shared-subnet-1", 
      "mock-shared-subnet-2", 
      "mock-shared-subnet-3"
    ]
  }
}

dependencies {
  paths = ["../../base"]
}

inputs = {
  # General variables
  env                  = include.env.locals.env
  region               = include.env.locals.region
  index                = include.env.locals.index 
  account_id           = include.env.locals.account_id 
  
  # VPC configuration
  inside_vpc           = false
  vpc_id               = dependency.mm_primary_vpc.outputs.mm_primary_vpc_id
  subnet_ids           = dependency.mm_primary_vpc.outputs.shared_private_subnet_id
  
  # Lambda configuration
  service              = "cancel_order_executor_hedging_orders"
  runtime              = "python3.12"
  handler              = "lambdas.rms.stop_process.stop_process_handler"
  memory_size          = 1024

  
  # Tags
  tags = include.env.locals.tags
}