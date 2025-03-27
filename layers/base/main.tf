################################################################################
# VPC
################################################################################

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  private_subnet_cidrs = [for i in range(var.number_of_private_subnets) : cidrsubnet(var.vpc_cidr, 8, i)]
  public_subnet_cidrs  = [for i in range(var.number_of_public_subnets) : cidrsubnet(var.vpc_cidr, 8, 255 - i)]  
  internet_cidr       = "0.0.0.0/0"
  internet_cidr_ipv6  = "::/0"
  rdp_port            = "3389"
  dns_port            = 53
  tcp_protocol_id     = "6"
  tunnel_identifier   = "tunnel"
  name                = "${var.organization}-${var.env}-${var.index}-${var.service}-vpc"
  tags                = var.tags
  create_ec2          = var.env == "stage"
  create_asg          = var.env == "prod"
}

module "mm_primary_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5.3"

  name              = local.name
  cidr              = var.vpc_cidr
  azs               = slice(data.aws_availability_zones.available.names, 0, var.number_of_azs)
  private_subnets   = local.private_subnet_cidrs
  public_subnets    = local.public_subnet_cidrs

  public_subnet_names = [
    "${var.organization}-${var.env}-${var.index}-${var.service}-public-subnet-1",
    "${var.organization}-${var.env}-${var.index}-${var.service}-public-subnet-2",
    "${var.organization}-${var.env}-${var.index}-${var.service}-public-subnet-3"    
  ]
  private_subnet_names = [
    "${var.organization}-${var.env}-${var.index}-${var.service}-shared-private-subnet-1",    
    "${var.organization}-${var.env}-${var.index}-${var.service}-shared-private-subnet-2",
    "${var.organization}-${var.env}-${var.index}-${var.service}-shared-private-subnet-3",
    "${var.organization}-${var.env}-${var.index}-${var.service}-desk-private-subnet-1",    
    "${var.organization}-${var.env}-${var.index}-${var.service}-desk-private-subnet-2",
    "${var.organization}-${var.env}-${var.index}-${var.service}-desk-private-subnet-3", 
    "${var.organization}-${var.env}-${var.index}-${var.service}-bot-private-subnet-1",    
    "${var.organization}-${var.env}-${var.index}-${var.service}-bot-private-subnet-2",
    "${var.organization}-${var.env}-${var.index}-${var.service}-bot-private-subnet-3", 
    "${var.organization}-${var.env}-${var.index}-${var.service}-analytics-private-subnet-1",    
    "${var.organization}-${var.env}-${var.index}-${var.service}-analytics-private-subnet-2",
    "${var.organization}-${var.env}-${var.index}-${var.service}-analytics-private-subnet-3", 
    "${var.organization}-${var.env}-${var.index}-${var.service}-db-private-subnet-1",    
    "${var.organization}-${var.env}-${var.index}-${var.service}-db-private-subnet-2",
    "${var.organization}-${var.env}-${var.index}-${var.service}-db-private-subnet-3", 
    "${var.organization}-${var.env}-${var.index}-${var.service}-dev-private-subnet-1",    
    "${var.organization}-${var.env}-${var.index}-${var.service}-dev-private-subnet-2",
    "${var.organization}-${var.env}-${var.index}-${var.service}-dev-private-subnet-3", 
    "${var.organization}-${var.env}-${var.index}-${var.service}-business-private-subnet-1",    
    "${var.organization}-${var.env}-${var.index}-${var.service}-business-private-subnet-2",
    "${var.organization}-${var.env}-${var.index}-${var.service}-business-private-subnet-3", 
    "${var.organization}-${var.env}-${var.index}-${var.service}-tunnel-private-subnet-1",    
    "${var.organization}-${var.env}-${var.index}-${var.service}-tunnel-private-subnet-2",
    "${var.organization}-${var.env}-${var.index}-${var.service}-tunnel-private-subnet-3",
    "${var.organization}-${var.env}-${var.index}-${var.service}-desk-alb-private-subnet-1",    
    "${var.organization}-${var.env}-${var.index}-${var.service}-desk-alb-private-subnet-2",
    "${var.organization}-${var.env}-${var.index}-${var.service}-desk-alb-private-subnet-3",
         
  ]

  // Need to add RDP block
  default_network_acl_ingress = [
    {
      rule_no    = 80
      action     = "deny"
      from_port  = local.rdp_port
      to_port    = local.rdp_port
      protocol   = local.tcp_protocol_id
      cidr_block = local.internet_cidr
    },
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = local.internet_cidr
    },   
  ]

  default_network_acl_egress = [
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
    },
  ]
  
  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false

  enable_flow_log = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_cloudwatch_log_group_name_prefix = "${var.organization}-${var.env}/${var.index}/${var.service}-vpc/flow-log-"
  flow_log_cloudwatch_log_group_retention_in_days = 365
  default_security_group_tags = local.tags
  default_security_group_ingress = []
  default_security_group_egress  = []
  tags = local.tags
  vpc_tags = {
    Name = "${local.name}"
  }
  nat_eip_tags = {
    Name = "${local.name}-nat-eip"
  }
  nat_gateway_tags = {
    Name = "${local.name}-nat-gw"
  }
  private_route_table_tags = {
    Name = "${local.name}-private-rt"
  }
  public_route_table_tags = {
    Name = "${local.name}-public-rt"
  }
  igw_tags = {
    Name = "${local.name}-igw"
  }
}


####################################################################################
# Cloudflare tunnel vm
# TBD - This is for enabling WARP, Need to discuss viability for enterprise or prod
#####################################################################################

module "mm_primary_tunnel_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name                  = "${var.organization}-${var.env}-${var.index}-${var.service}-${local.tunnel_identifier}-vm-sg"
  description           = "security group for desk-bot ${local.tunnel_identifier} vm"
  vpc_id                = module.mm_primary_vpc.vpc_id
  egress_rules          = ["all-all"]
  egress_cidr_blocks    = [local.internet_cidr]
  tags                  = local.tags
}

# EC2 Instance for stage environment
module "mm_primary_tunnel_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"
  
  count = local.create_ec2 ? 1 : 0

  name                        = "${var.organization}-${var.env}-${var.index}-${var.service}-${local.tunnel_identifier}-vm"
  ami                         = var.tunnel_ami
  instance_type               = var.tunnel_instance_type
  subnet_id                   = module.mm_primary_vpc.private_subnets[22]
  vpc_security_group_ids      = [module.mm_primary_tunnel_security_group.security_group_id]
  associate_public_ip_address = false
  user_data                   = base64encode(
    <<-EOF
    #!/bin/bash
    sudo apt-get update && sudo apt-get upgrade -y    
    sudo apt-get install collectd -y    
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
    wget https://cs-ec2-agent-config.s3.amazonaws.com/cloudwatch-agent-config.json
    sudo mv cloudwatch-agent-config.json /opt/aws/amazon-cloudwatch-agent/etc/
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-agent-config.json -s

    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb &&
    sudo dpkg -i cloudflared.deb &&
    sudo cloudflared service install ${var.tunnel_key}
    EOF
  )
  metadata_options            = {
    "http_endpoint"               = "enabled"
    "http_put_response_hop_limit" = 1
    "http_tokens"                 = "required"
  }

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = var.ebs_throughput
      volume_size = 8
    }
  ]
  
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for ${var.organization}-${var.env}-${var.index}-${var.service}-${local.tunnel_identifier}-vm"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    CloudWatchAgentServerPolicy  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  } 
  
  tags = local.tags
}

# ASG for live environment
module "mm_primary_tunnel_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"
  
  count = local.create_asg ? 1 : 0
  
  name = "${var.organization}-${var.env}-${var.index}-${var.service}-${local.tunnel_identifier}-asg"
  
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = [module.mm_primary_vpc.private_subnets[21], module.mm_primary_vpc.private_subnets[22], module.mm_primary_vpc.private_subnets[23]]
  
  launch_template_name        = "${var.organization}-${var.env}-${var.index}-${var.service}-${local.tunnel_identifier}-lt"
  launch_template_description = "Launch template for ${var.organization}-${var.env}-${var.index}-${var.service}-${local.tunnel_identifier}"
  update_default_version      = true
  
  image_id          = var.tunnel_ami
  instance_type     = var.tunnel_instance_type
  ebs_optimized     = true
  enable_monitoring = true
  
  user_data = base64encode(<<-EOF
  #!/bin/bash
  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt-get install collectd -y
  wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
  sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
  wget https://cs-ec2-agent-config.s3.amazonaws.com/cloudwatch-agent-config.json
  sudo mv cloudwatch-agent-config.json /opt/aws/amazon-cloudwatch-agent/etc/
  sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-agent-config.json -s
  curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb &&
  sudo dpkg -i cloudflared.deb &&
  sudo cloudflared service install ${var.tunnel_key}
  EOF
  )
  
  metadata_options = {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  
  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      ebs = {
        encrypted   = true
        volume_type = "gp3"
        throughput  = var.ebs_throughput
        volume_size = 8
      }
    }
  ]
  
  network_interfaces = [
    {
      delete_on_termination = true
      device_index          = 0
      security_groups       = [module.mm_primary_tunnel_security_group.security_group_id]
      associate_public_ip_address = false
    }
  ]
  
  create_iam_instance_profile = true
  iam_role_name               = "${var.organization}-${var.env}-${var.index}-${var.service}-${local.tunnel_identifier}-role"
  iam_role_description        = "IAM role for ${var.organization}-${var.env}-${var.index}-${var.service}-${local.tunnel_identifier}-vm"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    CloudWatchAgentServerPolicy  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  }
  
  tags = local.tags
  
  tag_specifications = [
    {
      resource_type = "instance"
      tags          = local.tags
    },
    {
      resource_type = "volume"
      tags          = local.tags
    }
  ]
}