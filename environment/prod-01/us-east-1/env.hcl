locals {
  organization              = "brc"
  env                       = "stage"
  region                    = "ap-south-1"
  index                     = "01"
  tags                      = {
    Terraform               =   true
    Environment             =   local.env
  }  
}