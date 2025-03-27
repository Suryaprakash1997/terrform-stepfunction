######################
# VPC Outputs
######################
output "mm_primary_vpc_id" {
  description = "The ID of the Desk Bot VPC"
  value       = module.mm_primary_vpc.vpc_id
}

output "mm_primary_vpc_cidr_block" {
  description = "The CIDR block of the Desk Bot VPC"
  value       = module.mm_primary_vpc.vpc_cidr_block
}

# Public Subnets
output "public_subnet_id" {
  description = "List of all public subnet IDs"
  value       = [
    module.mm_primary_vpc.public_subnets[0],
    module.mm_primary_vpc.public_subnets[1],
    module.mm_primary_vpc.public_subnets[2]
  ]
}

output "public_subnet_1" {
  description = "ID of public subnet 1"
  value       = module.mm_primary_vpc.public_subnets[0]
}

output "public_subnet_2" {
  description = "ID of public subnet 2"
  value       = module.mm_primary_vpc.public_subnets[1]
}

output "public_subnet_3" {
  description = "ID of public subnet 3"
  value       = module.mm_primary_vpc.public_subnets[2]
}

# Shared Private Subnets
output "shared_private_subnet_id" {
  description = "List of shared private subnet IDs"
  value       = [
    module.mm_primary_vpc.private_subnets[0],
    module.mm_primary_vpc.private_subnets[1],
    module.mm_primary_vpc.private_subnets[2]
  ]
}

output "shared_private_subnet_1" {
  description = "ID of shared private subnet 1"
  value       = module.mm_primary_vpc.private_subnets[0]
}

output "shared_private_subnet_2" {
  description = "ID of shared private subnet 2"
  value       = module.mm_primary_vpc.private_subnets[1]
}

output "shared_private_subnet_3" {
  description = "ID of shared private subnet 3"
  value       = module.mm_primary_vpc.private_subnets[2]
}

# Desk Private Subnets
output "desk_private_subnet_id" {
  description = "List of desk private subnet IDs"
  value       = [
    module.mm_primary_vpc.private_subnets[3],
    module.mm_primary_vpc.private_subnets[4],
    module.mm_primary_vpc.private_subnets[5]
  ]
}

output "desk_private_subnet_1" {
  description = "ID of desk private subnet 1"
  value       = module.mm_primary_vpc.private_subnets[3]
}

output "desk_private_subnet_2" {
  description = "ID of desk private subnet 2"
  value       = module.mm_primary_vpc.private_subnets[4]
}

output "desk_private_subnet_3" {
  description = "ID of desk private subnet 3"
  value       = module.mm_primary_vpc.private_subnets[5]
}

# Bot Private Subnets
output "bot_private_subnet_id" {
  description = "List of bot private subnet IDs"
  value       = [
    module.mm_primary_vpc.private_subnets[6],
    module.mm_primary_vpc.private_subnets[7],
    module.mm_primary_vpc.private_subnets[8]
  ]
}

output "bot_private_subnet_1" {
  description = "ID of bot private subnet 1"
  value       = module.mm_primary_vpc.private_subnets[6]
}

output "bot_private_subnet_2" {
  description = "ID of bot private subnet 2"
  value       = module.mm_primary_vpc.private_subnets[7]
}

output "bot_private_subnet_3" {
  description = "ID of bot private subnet 3"
  value       = module.mm_primary_vpc.private_subnets[8]
}

# Analytics Private Subnets
output "analytics_private_subnet_id" {
  description = "List of analytics private subnet IDs"
  value       = [
    module.mm_primary_vpc.private_subnets[9],
    module.mm_primary_vpc.private_subnets[10],
    module.mm_primary_vpc.private_subnets[11]
  ]
}

output "analytics_private_subnet_1" {
  description = "ID of analytics private subnet 1"
  value       = module.mm_primary_vpc.private_subnets[9]
}

output "analytics_private_subnet_2" {
  description = "ID of analytics private subnet 2"
  value       = module.mm_primary_vpc.private_subnets[10]
}

output "analytics_private_subnet_3" {
  description = "ID of analytics private subnet 3"
  value       = module.mm_primary_vpc.private_subnets[11]
}

# DB Private Subnets
output "db_private_subnet_id" {
  description = "List of db private subnet IDs"
  value       = [
    module.mm_primary_vpc.private_subnets[12],
    module.mm_primary_vpc.private_subnets[13],
    module.mm_primary_vpc.private_subnets[14]
  ]
}

output "db_private_subnet_1" {
  description = "ID of db private subnet 1"
  value       = module.mm_primary_vpc.private_subnets[12]
}

output "db_private_subnet_2" {
  description = "ID of db private subnet 2"
  value       = module.mm_primary_vpc.private_subnets[13]
}

output "db_private_subnet_3" {
  description = "ID of db private subnet 3"
  value       = module.mm_primary_vpc.private_subnets[14]
}

# Dev Private Subnets
output "dev_private_subnet_id" {
  description = "List of dev private subnet IDs"
  value       = [
    module.mm_primary_vpc.private_subnets[15],
    module.mm_primary_vpc.private_subnets[16],
    module.mm_primary_vpc.private_subnets[17]
  ]
}

output "dev_private_subnet_1" {
  description = "ID of dev private subnet 1"
  value       = module.mm_primary_vpc.private_subnets[15]
}

output "dev_private_subnet_2" {
  description = "ID of dev private subnet 2"
  value       = module.mm_primary_vpc.private_subnets[16]
}

output "dev_private_subnet_3" {
  description = "ID of dev private subnet 3"
  value       = module.mm_primary_vpc.private_subnets[17]
}

# Business Private Subnets
output "business_private_subnet_id" {
  description = "List of business private subnet IDs"
  value       = [
    module.mm_primary_vpc.private_subnets[18],
    module.mm_primary_vpc.private_subnets[19],
    module.mm_primary_vpc.private_subnets[20]
  ]
}

output "business_private_subnet_1" {
  description = "ID of business private subnet 1"
  value       = module.mm_primary_vpc.private_subnets[18]
}

output "business_private_subnet_2" {
  description = "ID of business private subnet 2"
  value       = module.mm_primary_vpc.private_subnets[19]
}

output "business_private_subnet_3" {
  description = "ID of business private subnet 3"
  value       = module.mm_primary_vpc.private_subnets[20]
}

# Tunnel Private Subnets
output "tunnel_private_subnet_id" {
  description = "List of tunnel private subnet IDs"
  value       = [
    module.mm_primary_vpc.private_subnets[21],
    module.mm_primary_vpc.private_subnets[22],
    module.mm_primary_vpc.private_subnets[23]
  ]
}

output "tunnel_private_subnet_1" {
  description = "ID of tunnel private subnet 1"
  value       = module.mm_primary_vpc.private_subnets[21]
}

output "tunnel_private_subnet_2" {
  description = "ID of tunnel private subnet 2"
  value       = module.mm_primary_vpc.private_subnets[22]
}

output "tunnel_private_subnet_3" {
  description = "ID of tunnel private subnet 3"
  value       = module.mm_primary_vpc.private_subnets[23]
}

# Subnet CIDR blocks
output "public_subnet_cidrs" {
  description = "List of CIDR blocks of public subnets"
  value       = module.mm_primary_vpc.public_subnets_cidr_blocks
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of private subnets"
  value       = module.mm_primary_vpc.private_subnets_cidr_blocks
}


######################
# Security Group Outputs
######################
output "mm_primary_tunnel_security_group_id" {
  description = "ID of the tunnel security group for Desk Bot"
  value       = module.mm_primary_tunnel_security_group.security_group_id
}