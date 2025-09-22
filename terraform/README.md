# Terraform Infrastructure for Event Announcement System

This directory contains Terraform configuration to deploy the complete Event Announcement System infrastructure on AWS.

## Architecture

The Terraform configuration deploys:
- **S3 Bucket**: Static website hosting for frontend
- **Lambda Function**: Event processing and SNS publishing
- **API Gateway**: REST API endpoints
- **SNS Topic**: Multi-channel notifications (email/SMS)
- **IAM Roles**: Least privilege access policies
- **CloudWatch**: Logging and monitoring

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (>= 1.0)
3. **AWS permissions** for creating the required resources

## Quick Start

### 1. Configure Variables
```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Plan Deployment
```bash
terraform plan
```

### 4. Deploy Infrastructure
```bash
terraform apply
```

### 5. Get Outputs
```bash
terraform output
```

## Configuration

### Required Variables

Edit `terraform.tfvars`:

```hcl
aws_region   = "us-east-1"
environment  = "prod"
project_name = "event-announcement"

# Add your notification endpoints
email_subscriptions = [
  "your-email@example.com"
]

sms_subscriptions = [
  "+1234567890"
]
```

### Optional Backend Configuration

For production use, configure remote state storage:

1. Create an S3 bucket for Terraform state
2. Uncomment and configure the backend in `main.tf`:

```hcl
backend "s3" {
  bucket = "your-terraform-state-bucket"
  key    = "event-announcement-system/terraform.tfstate"
  region = "us-east-1"
}
```

## Module Structure

```
terraform/
├── main.tf                 # Main configuration
├── variables.tf            # Input variables
├── outputs.tf             # Output values
├── terraform.tfvars.example
└── modules/
    ├── s3/                # S3 static hosting
    ├── sns/               # SNS notifications
    ├── lambda/            # Lambda function
    └── api_gateway/       # API Gateway
```

## Outputs

After deployment, you'll get:

- **s3_website_url**: Frontend website URL
- **api_gateway_url**: API endpoint URL
- **sns_topic_arn**: SNS topic ARN
- **lambda_function_name**: Lambda function name

## Post-Deployment Steps

### 1. Upload Frontend Files
```bash
# Get bucket name
BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# Upload frontend files
aws s3 sync ../src/frontend/ s3://$BUCKET_NAME/ --acl public-read
```

### 2. Update Frontend Configuration
```bash
# Get API URL
API_URL=$(terraform output -raw api_gateway_url)

# Update script.js with the API URL
sed -i "s|https://your-api-id.execute-api.region.amazonaws.com/prod/events|$API_URL|g" ../src/frontend/script.js

# Re-upload updated script.js
aws s3 cp ../src/frontend/script.js s3://$BUCKET_NAME/ --acl public-read
```

### 3. Confirm SNS Subscriptions
- Check your email for SNS confirmation messages
- Click the confirmation links to activate subscriptions

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Cost Estimation

Monthly costs (approximate):
- **Lambda**: $0.20 per 1M requests
- **API Gateway**: $3.50 per 1M requests  
- **SNS**: $0.50 per 1M notifications
- **S3**: $0.023 per GB storage
- **CloudWatch**: $0.50 per GB logs

**Total**: ~$1-5/month for moderate usage

## Security Features

- **IAM Least Privilege**: Lambda only has SNS publish permissions
- **HTTPS Only**: All API communication encrypted
- **CORS Configured**: Secure cross-origin requests
- **Public S3 Policy**: Read-only access to website files

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure AWS credentials have required permissions
2. **Bucket Name Conflict**: Bucket names must be globally unique
3. **Lambda Deployment**: Ensure source code exists in `../src/lambda/`

### Useful Commands

```bash
# Check Terraform state
terraform state list

# View specific resource
terraform state show module.lambda_processor.aws_lambda_function.processor

# Import existing resource
terraform import module.sns_notifications.aws_sns_topic.notifications arn:aws:sns:us-east-1:123456789012:topic-name

# Refresh state
terraform refresh
```

## Best Practices

1. **Use Remote State**: Configure S3 backend for team collaboration
2. **Version Control**: Commit `.tf` files, exclude `.tfstate` and `.tfvars`
3. **Environment Separation**: Use workspaces or separate directories
4. **Resource Tagging**: All resources tagged with project and environment
5. **State Locking**: Use DynamoDB for state locking in production

## Contributing

1. Follow Terraform best practices
2. Update documentation for any changes
3. Test changes in a separate environment first
4. Use consistent naming conventions
