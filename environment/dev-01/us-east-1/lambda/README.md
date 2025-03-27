```hcl
    inputs = {
    #############################
    # REQUIRED INPUTS
    #############################
    
    # General variables (required)
    env                  = include.env.locals.env          # Environment (dev, stage, prod)
    region               = include.env.locals.region       # AWS region
    index                = include.env.locals.index        # Deployment index or identifier
    
    # Lambda-specific required configuration
    service              = "my-lambda-service"             # Service name
    handler              = "index.handler"                 # Handler function
    
    #############################
    # COMMON CONFIGURATION
    #############################
    
    # Lambda settings
    memory_size          = 256                             # Memory allocation in MB (default: 128)
    timeout              = 30                              # Timeout in seconds (default: 600)
    
    # Feature flags
    inside_vpc           = true                            # Whether Lambda should be in a VPC
    create_scheduler     = false                           # Whether to create a CloudWatch Events scheduler
    
    # VPC configuration (required if inside_vpc = true)
    vpc_id               = dependency.vpc.outputs.vpc_id
    subnet_ids           = dependency.vpc.outputs.private_subnet_ids
    
    #############################
    # OPTIONAL CONFIGURATION
    #############################
    
    
    # Scheduler configuration (used if create_scheduler = true)
    schedule_expression = "rate(5 minutes)"                # How often the Lambda should be triggered
    
    #############################
    # IAM CONFIGURATION
    #############################
    
    # Predefined AWS policies to attach
    existing_policies = [
        "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess",
        # Add more policies as needed
    ]
    
    # Custom policy (inline JSON)
    custom_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
        {
            Effect = "Allow",
            Action = [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:Query",
            "dynamodb:Scan"
            ],
            Resource = "arn:aws:dynamodb:*:*:table/my-service-table"
        },
        {
            Effect = "Allow",
            Action = [
            "s3:GetObject",
            "s3:PutObject"
            ],
            Resource = "arn:aws:s3:::my-bucket/*"
        }
        ]
    })
    
    #############################
    # TAGGING
    #############################
    
    # Tags (merge with environment tags)
    tags = merge(
        include.env.locals.tags,
        {
        Service     = "my-lambda-service"
        Owner       = "backend_developer"
        env  = "stage"
        }
    )
    }