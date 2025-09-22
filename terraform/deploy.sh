#!/bin/bash

# Event Announcement System - Terraform Deployment Script

set -e

echo "🚀 Event Announcement System - Terraform Deployment"
echo "=================================================="

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ terraform.tfvars not found!"
    echo "📝 Please copy terraform.tfvars.example to terraform.tfvars and configure your values"
    exit 1
fi

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Ask for confirmation
read -p "🤔 Do you want to apply these changes? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

# Apply changes
echo "🚀 Applying changes..."
terraform apply tfplan

# Get outputs
echo "📊 Deployment completed! Here are your resources:"
echo "================================================"
terraform output

# Get values for post-deployment steps
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
API_URL=$(terraform output -raw api_gateway_url)

echo ""
echo "📝 Next Steps:"
echo "=============="
echo "1. Upload frontend files:"
echo "   aws s3 sync ../src/frontend/ s3://$BUCKET_NAME/ --acl public-read"
echo ""
echo "2. Update frontend API URL:"
echo "   sed -i 's|https://your-api-id.execute-api.region.amazonaws.com/prod/events|$API_URL|g' ../src/frontend/script.js"
echo "   aws s3 cp ../src/frontend/script.js s3://$BUCKET_NAME/ --acl public-read"
echo ""
echo "3. Confirm SNS email subscriptions (check your email)"
echo ""
echo "🎉 Your Event Announcement System is ready!"

# Clean up plan file
rm -f tfplan
