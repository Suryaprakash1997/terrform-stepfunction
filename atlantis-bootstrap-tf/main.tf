provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # VPC
  vpc_name              =   "${var.organization}-${var.env}-${var.index}-${var.service}-vpc"
  vpc_cidr              =   "10.25.0.0/16"
  private_subnet_cidrs  =   ["10.25.0.0/24","10.25.1.0/24","10.25.2.0/24"]
  public_subnet_cidrs   =   ["10.25.255.0/24","10.25.254.0/24","10.25.253.0/24"]
  ami                   =   "ami-084568db4383264d4"
  internet_cidr         =   "0.0.0.0/0"
  tunnel_ec2            =   "${var.organization}-${var.env}-${var.index}-${var.service}-vpc-tunnel-vm"
  tunnel_security_group =   "${var.organization}-${var.env}-${var.index}-${var.service}-vpc-tunnel-vm-sg"
  tunnel_key            =   "eyJhIjoiOTgxNGYwYjAxOTJiODhlZDgxNWM4YWNjNjYzMjc5OWMiLCJ0IjoiYTE0OTdlZGYtOThjZC00NjcxLWE3OTgtZWE5YTRiODVmOWFlIiwicyI6IlpETmtPRGRrTmpBdE5tTmtaUzAwT0RkaUxUZ3pZekV0TWpJMVpXTTNZVGswWmpSbCJ9"
  
  # Bitbucket IP's
  ipv4_cidr_blocks           = [
                            "104.192.136.0/21",
                            "185.166.140.0/22",
                            "13.200.41.128/25"
                          ]
  ipv6_cidr_blocks      = [
                            "2401:1d80:320c:3::/64",
                            "2401:1d80:320c:4::/64",
                            "2401:1d80:320c:5::/64",
                            "2401:1d80:3208::/64",
                            "2401:1d80:3208:1::/64",
                            "2401:1d80:3208:2::/64",
                            "2401:1d80:3210::/64",
                            "2401:1d80:3210:1::/64",
                            "2401:1d80:3210:2::/64",
                            "2401:1d80:321c::/64",
                            "2401:1d80:321c:1::/64",
                            "2401:1d80:321c:2::/64",
                            "2401:1d80:322c:2::/64",
                            "2401:1d80:322c:3::/64",
                            "2401:1d80:322c:5::/64",
                            "2401:1d80:3218:1::/64",
                            "2401:1d80:3218:3::/64",
                            "2401:1d80:3218:4::/64",
                            "2401:1d80:3220::/64",
                            "2401:1d80:3220:1::/64",
                            "2401:1d80:3224::/64",
                            "2401:1d80:3224:1::/64",
                            "2401:1d80:3224:2::/64"
                          ]

  
  # ACM certificate data
  certificate_domain    =   "*.suryaselva.xyz" // change after yadhu certificate
  
  # Container configuration
  container_name        =   "atlantis"
  container_image       =   "319727410053.dkr.ecr.us-east-1.amazonaws.com/brc-infra-01-atlantis-image:latest"
  container_port        =   4141
  
  # CloudWatch logs
  log_group_name        =   "${var.organization}-${var.env}-${var.index}-${var.service}-logs"
  log_retention_days    =   7

  # Tags
  tags = {
    Environment         =   var.env
    Service             =   var.service
    Terraform           =   "true"
  }
}

resource "random_string" "webhook_secret" {
  length  = 128
  special = false
}

resource "aws_secretsmanager_secret" "atlantis_webhook_secret" {
  name        = "${var.organization}-${var.env}-${var.index}-${var.service}-bitbucket-webhook-secrets"
  description = "Webhook secret for Atlantis Bitbucket integration"
  
  tags = merge(local.tags, {
    Name = "${var.organization}-${var.env}-${var.index}-${var.service}-webhook-secret"
  })
}

resource "aws_secretsmanager_secret_version" "atlantis_webhook_secret" {
  secret_id     = aws_secretsmanager_secret.atlantis_webhook_secret.id
  secret_string = random_string.webhook_secret.result
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5.3"

  name              =   local.vpc_name
  cidr              =   local.vpc_cidr
  azs               =   slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets   =   local.private_subnet_cidrs
  public_subnets    =   local.public_subnet_cidrs

  // Need to add RDP block
  default_network_acl_ingress = [
    {
      rule_no    = 80
      action     = "deny"
      from_port  = 3389
      to_port    = 3389
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
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
  
  enable_nat_gateway      =   true
  single_nat_gateway      =   true
  one_nat_gateway_per_az  =   false

  enable_flow_log = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_cloudwatch_log_group_name_prefix = "${var.organization}-${var.env}-${var.index}-${var.service}-vpc/flow-log-"
  flow_log_cloudwatch_log_group_retention_in_days = 365

  default_security_group_ingress = []
  default_security_group_egress  = []
  vpc_tags = {
    Name = "${local.vpc_name}-vpc"
  }
  nat_eip_tags = {
    Name = "${local.vpc_name}-nat-eip"
  }
  nat_gateway_tags = {
    Name = "${local.vpc_name}-nat-gw"
  }
  private_route_table_tags = {
    Name = "${local.vpc_name}-private-rt"
  }
  public_route_table_tags = {
    Name = "${local.vpc_name}-public-rt"
  }
  igw_tags = {
    Name = "${local.vpc_name}-igw"
  }
}

module "tunnel_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name                  = local.tunnel_security_group
  description           = "security group for vpc tunnel ec2"
  vpc_id                = module.vpc.vpc_id
  egress_rules          = ["all-all"]
  egress_cidr_blocks    = [local.internet_cidr]
  tags                  = local.tags
}

module "tunnel_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"

  name                          = local.tunnel_ec2
  ami                           = local.ami
  instance_type                 = "t3.micro"
  subnet_id                     = module.vpc.private_subnets[0]
  vpc_security_group_ids        = [module.tunnel_security_group.security_group_id]
  associate_public_ip_address   = false
  user_data                     = base64encode(
    <<-EOF
    #!/bin/bash
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
    wget https://cs-ec2-agent-config.s3.amazonaws.com/cloudwatch-agent-config.json
    sudo mv cloudwatch-agent-config.json /opt/aws/amazon-cloudwatch-agent/etc/    
    sudo apt-get install collectd -y
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-agent-config.json -s
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb &&
    sudo dpkg -i cloudflared.deb &&
    sudo cloudflared service install ${local.tunnel_key}
  EOF
  )
  metadata_options              = {
    "http_endpoint"               = "enabled"
    "http_put_response_hop_limit" = 1
    "http_tokens"                 = "required"
  }

    root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 10
    }
  ]
  // Instance Role
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for default VPC tunnel Ec2"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore  = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    CloudWatchAgentServerPolicy   = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  } 
  tags   = local.tags
  depends_on = [ module.vpc ]
}

# Fetch the current AWS account ID
data "aws_caller_identity" "current" {}

# 🔹 ACM Certificate
data "aws_acm_certificate" "atlantis-cert" {
  domain      = local.certificate_domain
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# 🔹 CloudWatch Log Group
resource "aws_cloudwatch_log_group" "atlantis" {
  name              = local.log_group_name
  retention_in_days = local.log_retention_days
  tags              = local.tags
}

# 🔹 ECS Cluster using module
module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 5.9.1"

  cluster_name = "${var.organization}-${var.env}-${var.index}-${var.service}-cluster"
  
  cluster_settings = {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = local.tags
}

# 🔹 External ALB Security Group
resource "aws_security_group" "atlantis_alb_sg" {
  vpc_id = module.vpc.vpc_id
  name   = "${var.organization}-${var.env}-${var.index}-${var.service}-alb-sg"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.ipv4_cidr_blocks
    description = "Allow Bitbucket inbound traffic (IPv4)"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    ipv6_cidr_blocks = local.ipv6_cidr_blocks
    description = "Allow Bitbucket inbound traffic (IPv6)"
  }

  # Existing egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = local.tags
}

# 🔹 Internal ALB Security Group
resource "aws_security_group" "atlantis_internal_alb_sg" {
  vpc_id = module.vpc.vpc_id
  name   = "${var.organization}-${var.env}-${var.index}-${var.service}-internal-alb-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
    description = "Allow HTTP traffic from within VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = local.tags
}

# 🔹 ALB Log Bucket
module "alb_log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1.0"
  
  bucket        = "${var.organization}-${var.env}-${var.index}-${var.service}-alb-logs"
  force_destroy = true
  
  attach_elb_log_delivery_policy     = true
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
  
  tags = local.tags
}

# 🔹 External ALB (HTTPS)
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.7.0"

  name               = "${var.organization}-${var.env}-${var.index}-${var.service}-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.atlantis_alb_sg.id]
  internal           = false

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = data.aws_acm_certificate.atlantis-cert.arn
      ssl_policy         = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name                 = "${var.organization}-${var.env}-${var.index}-${var.service}-tg"
      backend_protocol     = "HTTP"
      backend_port         = local.container_port
      target_type          = "ip"
      deregistration_delay = 300
      health_check = {
        path                = "/healthz"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 3
        matcher             = "200"
      }
    }
  ]

  access_logs = {
    bucket = module.alb_log_bucket.s3_bucket_id
    prefix = "alb-logs"
    enabled = true
  }
  
  tags = local.tags

  depends_on = [ module.vpc ]
}

# 🔹 Internal ALB (HTTP)
module "internal_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.7.0"

  name               = "${var.organization}-${var.env}-${var.index}-${var.service}-int-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.private_subnets
  security_groups    = [aws_security_group.atlantis_internal_alb_sg.id]
  internal           = true

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name                 = "${var.organization}-${var.env}-${var.index}-${var.service}-int-tg"
      backend_protocol     = "HTTP"
      backend_port         = local.container_port
      target_type          = "ip"
      deregistration_delay = 300
      health_check = {
        path                = "/healthz"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 3
        matcher             = "200"
      }
    }
  ]
  
  tags = local.tags

  depends_on = [module.vpc]
}

# 🔹 ECS Service using module with integrated task definition
module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 5.9.1"

  name                         = "${var.organization}-${var.env}-${var.index}-${var.service}-service"
  desired_count                = 1
  cluster_arn                  = module.ecs_cluster.arn
  wait_for_steady_state        = true
  force_new_deployment         = true
  
  # Task definition configurations
  cpu                      = "4096"
  memory                   = "8192"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  
  subnet_ids               = module.vpc.private_subnets
  security_group_rules     = {
    ingress_from_public_alb = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "Allow traffic from public ALB to Atlantis"
      source_security_group_id = aws_security_group.atlantis_alb_sg.id
    }
    ingress_from_internal_alb = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "Allow traffic from internal ALB to Atlantis"
      source_security_group_id = aws_security_group.atlantis_internal_alb_sg.id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  
  deployment_circuit_breaker = {
    enable   = true
    rollback = true
  }
  
  load_balancer = [
    {
      container_name   = local.container_name
      container_port   = local.container_port
      target_group_arn = module.alb.target_group_arns[0]
    },
    {
      container_name   = local.container_name
      container_port   = local.container_port
      target_group_arn = module.internal_alb.target_group_arns[0]
    }
  ]

  # IAM roles
  create_iam_role          = true
  tasks_iam_role_name      = "${var.organization}-${var.env}-${var.index}-${var.service}-tasks"
  tasks_iam_role_description = "Atlantis task IAM role for ${var.organization}-${var.env}-${var.index}-${var.service}"
  tasks_iam_role_policies  = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }
  create_task_exec_iam_role = true
  enable_execute_command = true

  # Container definition
  container_definitions = {
    (local.container_name) = {
      name            = local.container_name
      image           = local.container_image
      cpu             = 4096
      memory          = 8192
      essential       = true
      readonly_root_filesystem = false
      
      port_mappings = [
        {
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      
      environment = [
        { name = "ATLANTIS_ALLOW_REPO_CONFIG", value = "true" },
        { name = "ATLANTIS_WRITE_GIT_CREDS", value = "true" },
        { name = "ATLANTIS_REPO_CONFIG_JSON", value = "{\"repos\":[{\"id\":\"bitbucket.org/brownrice-capital/infrastructure-tf\",\"allowed_overrides\":[\"workflow\"],\"allow_custom_workflows\":true}]}" },
        { name = "ATLANTIS_REPO_ALLOWLIST", value = "bitbucket.org/brownrice-capital/infrastructure-tf" },
        { name = "ATLANTIS_PORT", value = tostring(local.container_port) },
        { name = "ATLANTIS_DEBUG", value = "true" },
        { name = "ATLANTIS_BITBUCKET_CLOUD", value = "true" },
        { name = "ATLANTIS_BITBUCKET_TOKEN_TYPE", value = "basic" },
        { name = "ATLANTIS_ALLOW_REPO_CONFIG_WORKFLOW", value = "true" },
        { name = "ATLANTIS_ENABLE_REPO_CONFIG", value = "true" },
        { name = "ATLANTIS_ATLANTIS_URL", value = "https://atlantis.suryaselva.xyz" }
      ],
      
      secrets = [
        {
          name = "ATLANTIS_BITBUCKET_WEBHOOK_SECRET",
          valueFrom = aws_secretsmanager_secret.atlantis_webhook_secret.arn
        },
        {
          name = "ATLANTIS_BITBUCKET_USER",
          valueFrom = "arn:aws:secretsmanager:us-east-1:319727410053:secret:brc-infra-01-bitbucket-secrets-92EdKS:ATLANTIS_BITBUCKET_USER::"
        },
        {
          name = "ATLANTIS_BITBUCKET_TOKEN",
          valueFrom = "arn:aws:secretsmanager:us-east-1:319727410053:secret:brc-infra-01-bitbucket-secrets-92EdKS:ATLANTIS_BITBUCKET_TOKEN::"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.atlantis.name,
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "atlantis"
        }
      }
    }
  }
  
  ignore_task_definition_changes = false
  depends_on = [module.alb, module.internal_alb]
  tags = local.tags
}

