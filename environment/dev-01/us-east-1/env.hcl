locals {
  organization              = "brc"
  env                       = "stage"
  region                    = "us-east-1"
  index                     = "01"
  account_id                = "597189966628"
  tags                      = {
    Terraform               =   true
    Environment             =   local.env
  }  
}