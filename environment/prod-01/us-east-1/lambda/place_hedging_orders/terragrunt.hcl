terraform {
  source = "../../../../layers/lambda"
  
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
  
  # VPC configuration
  inside_vpc           = true
  vpc_id               = dependency.mm_primary_vpc.outputs.mm_primary_vpc_id
  subnet_ids           = dependency.mm_primary_vpc.outputs.shared_private_subnet_id
  
  # Lambda configuration
  service              = "place_hedging_orders"
  runtime              = "python3.12"
  handler              = "lambdas.inr-hedging.place_hedging_orders.place_hedging_orders_handler"
  memory_size          = 1024

  existing_policies = ["arn:aws:iam::aws:policy/AWSLambdaBasicExecutionRole", "harshil arn"]
  custom_policy = 

  # Tags
  tags = include.env.locals.tags
}