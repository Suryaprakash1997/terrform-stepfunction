terraform {
  source = "../../../../layers/base"
}

include "root" {
  path                = find_in_parent_folders()
}

include "env" {
  path                =   find_in_parent_folders("env.hcl")
  expose              =   true
  merge_strategy      =   "no_merge"
}

inputs = {

  organization                          =   include.env.locals.organization
  env                                   =   include.env.locals.env
  region                                =   include.env.locals.region
  index                                 =   include.env.locals.index
  number_of_azs                         =   3
  number_of_private_subnets             =   27
  number_of_public_subnets              =   3
  vpc_cidr                              =   "10.0.0.0/16"
  product                               =   "mm_primary"
  tunnel_instance_type                  =   "t3a.micro"
  tunnel_key                            =   "eyJhIjoiOTgxNGYwYjAxOTJiODhlZDgxNWM4YWNjNjYzMjc5OWMiLCJ0IjoiNzE0Y2M3NDAtZTlhNC00MzAwLWFjNjAtZDMxNDNkOTAzYzE0IiwicyI6Ik9ETTBabUl3TUdRdE5HTTNOQzAwTXprd0xXSTRZVFV0TmpZeFkyVmlZalU1WW1abCJ9"
  tunnel_ami                            =   "ami-084568db4383264d4"
  tags                                  =   include.env.locals.tags
}