
# ATLANTIS DEPLOYMENT STEPS

## Prerequisites:
1. **Bitbucket Repository Credentials**:
   - Store Bitbucket username and app password in AWS Secrets Manager
   - Update the ARN of this secret in `atlantis-bootstrap-tf/main.tf` for the ECS environment variables `ATLANTIS_BITBUCKET_USER` and `ATLANTIS_BITBUCKET_TOKEN`

2. **SSL Certificate**:
   - Valid SSL certificate must be available in AWS Certificate Manager (ACM)

3. **Infrastructure Setup**:
    - Create a VPC in the infrastructure account with a public subnet connected to an Internet Gateway
    - Deploy an EC2 instance with accessible only via AWS Systems Manager for running Atlantis Terraform with following specifications
        - Userdata (refer scripts/scripts.sh)
        - Instance type - t3.medium
        - Storage - 20 GB
        - IAM role - admin access
        (Note: One the atlantis is up and running stop this instance, whenever there is a change in atlantis configuration turn it on and pull the change from git and run terraform)
    - Create a repository `brc-infra-01-atlantis-image` in the same region as atlantis server is created (us-east-1)

4. **Configuration Variables**:
   - Add the following variables to `main.tf` in `atlantis-bootstrap-tf`:
     - `ATLANTIS_REPO_ALLOWLIST`
     - `ATLANTIS_REPO_CONFIG_JSON`
     - `ATLANTIS_ATLANTIS_URL` (DNS name that will point to the public ALB)

5. **IAM Role Secret String**:
    - Create 128 bit random secret string and store it in secrets manager.

## Step 1: Deploy Atlantis
1. Access the Terraform runner EC2 instance via SSM Manager
2. Create a docker image using docker file (atlantis-bootstrap-tf/Dockerfile)
2. Clone the `infrastructure-tf` repository
3. Navigate to `infrastructure-tf/atlantis-bootstrap-tf`
5. Execute Terraform commands:
```bash
# Initialize Terraform
terraform init

# Create an execution plan
terraform plan

# Apply the changes
terraform apply
```
5. Configure DNS by mapping the Atlantis public ALB endpoint to your HTTPS domain name
6. Note that Atlantis Terraform creates a webhook secret stored in Secrets Manager under `brc-infra-01-atlantis-bitbucket-secret`
7. Configure a webhook in Bitbucket using:
- The DNS name created for Atlantis
- The secret from `brc-infra-01-atlantis-bitbucket-secret`
8. Atlantis UI can be accessed by private-alb through tunnel

## Step 2: Configure Cross-Account Access
1. Create an administrator cross-account role in each target account (stage, prod, dev)
2. Reference the template in `cross-account-role-template/policy.json` for the IAM policy configuration
3. In the role add the secret string created for IAM role
        
    ```json
    "Condition": {
        "StringEquals": {
            "sts:ExternalId": "<string-here>",
            "aws:PrincipalArn": "<atlantis-task-role-ARN-here>"
        }
    }
    ```

   
## steps 3: Infra creation configuration:
### Lambda
1. To add a new Lambda service, go to the folder `environment/dev-01/us-east-1/lambda/` and create a folder name with the service name. Inside this folder, create a terragrunt.hcl file.
2. Refer an existing Lambda terragrunt.hcl file as a reference and copy all values except the inputs block.
3. Update the inputs section with the necessary variables specific to the new service. You can refer to the sample configurations in `environment/dev/lambda/README.md` for guidance.
4. Update the atlantis.yaml file located in the root directory by adding a new project entry for the service under projects, similar to the structure below:
    ```yaml
    ##reference.yaml
    name: dev-01/ap-south-1/lambda/{service_name}
    dir: environment/dev-01/ap-south-1/lambda/{service_name`
    workflow: terragrunt-run-all
    branch: /dev-01/ap-south-1/
    autoplan:
    when_modified: 
        - "environment/dev-01/ap-south-1/lambda/{service_name}/**"
        - "layers/lambda/{service_name}/**"
        - "environment/dev-01/ap-south-1/env.hcl"
        - "environment/dev-01/ap-south-1/terragrunt.hcl"
    ```

Note: Replace {service_name} with the folder name of your new Lambda service.

5. After adding the config commit and push it to bitbucket.
6. While approving the PR, add a comment: atlantis plan -p dev-01/ap-south-1-lambda-{service_name}. You can monitor the live logs in the Atlantis UI. Once the plan is completed, review it and then comment atlantis apply -p dev-01/ap-south-1-lambda-{service_name} on the PR to apply the changes.
(Note: This is a temporary step and may change after further discussion.)

### Please ensure that the Lambda service name does not exceed 40 characters, as exceeding this limit will result in an exception.
    