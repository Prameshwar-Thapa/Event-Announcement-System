#!/bin/bash

# Script to update frontend with API Gateway URL from Terraform outputs

echo "🔄 Updating frontend with API Gateway URL..."

# Get the API Gateway URL from Terraform outputs
cd terraform
API_URL=$(terraform output -raw api_gateway_url 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$API_URL" ]; then
    echo "❌ Error: Could not get API Gateway URL from Terraform outputs"
    echo "   Make sure you have run 'terraform apply' successfully"
    exit 1
fi

echo "📡 Found API Gateway URL: $API_URL"

# Update the script.js file
cd ../src/frontend
if [ ! -f "script.js" ]; then
    echo "❌ Error: script.js not found in src/frontend/"
    exit 1
fi

# Create backup
cp script.js script.js.backup

# Replace the API endpoint
sed -i "s|API_ENDPOINT: 'REPLACE_WITH_API_GATEWAY_URL'|API_ENDPOINT: '$API_URL'|g" script.js

if [ $? -eq 0 ]; then
    echo "✅ Successfully updated script.js with API Gateway URL"
    echo "🔄 Re-uploading to S3..."
    
    # Get S3 bucket name
    cd ../../terraform
    BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null)
    
    if [ ! -z "$BUCKET_NAME" ]; then
        # Upload updated script.js to S3
        aws s3 cp ../src/frontend/script.js s3://$BUCKET_NAME/script.js --content-type "application/javascript"
        echo "✅ Updated script.js uploaded to S3"
        echo "🌐 Your website should now work properly!"
    else
        echo "⚠️  Could not get S3 bucket name. Please manually upload script.js to S3"
    fi
else
    echo "❌ Error updating script.js"
    exit 1
fi
