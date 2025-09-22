# AWS Console Guide: Event Announcement System

## Table of Contents
1. [Project Overview](#project-overview)
2. [Set up frontend hosting with S3](#set-up-frontend-hosting-with-s3)
3. [Integrate SNS Notifications and Lambda Functions](#integrate-sns-notifications-and-lambda-functions)
4. [Setup, Test and Deploy the API Gateway](#setup-test-and-deploy-the-api-gateway)
5. [Test and Finalize](#test-and-finalize)
6. [Project Conclusion and Clean-up](#project-conclusion-and-clean-up)

---

## Project Overview

### What You'll Build
A serverless event announcement system that allows administrators to:
- Create event announcements through a web interface
- Send notifications to subscribers via email and SMS
- Manage subscriber lists
- Track notification delivery status

### Architecture Components
```
User Interface (S3) → API Gateway → Lambda Function → SNS Topic → Email/SMS
```

### Services Used
- **Amazon S3**: Static website hosting for admin interface
- **API Gateway**: REST API endpoints for frontend communication
- **AWS Lambda**: Event processing and business logic
- **Amazon SNS**: Multi-channel notification delivery
- **CloudWatch**: Monitoring and logging

### Time Required
⏱️ **30-45 minutes** for complete deployment

### Cost Estimate
💰 **Free tier eligible** - Estimated $0-5/month for moderate usage

---

## Set up frontend hosting with S3

### Step 1: Create S3 Bucket for Website Hosting

#### Access S3 Service
1. **Sign in to AWS Console**
   - Go to: https://console.aws.amazon.com
   - Enter your credentials

2. **Navigate to S3**
   - In the search bar, type "S3"
   - Click "Amazon S3" from the results

#### Create the Bucket
1. **Click "Create bucket"**
   - Large orange button on the S3 dashboard

2. **Configure Bucket Settings**
   ```
   Bucket name: event-announcements-frontend-[your-initials]-[random-number]
   Example: event-announcements-frontend-js-12345
   
   AWS Region: Choose your preferred region (e.g., us-east-1)
   ```

3. **Public Access Settings**
   - **Uncheck** "Block all public access"
   - **Check** the acknowledgment box
   - This allows public access for website hosting

4. **Create Bucket**
   - Click "Create bucket" button
   - Wait for confirmation message

**Validation Check:** You should see your new bucket in the S3 buckets list.

### Step 2: Configure Static Website Hosting

#### Enable Website Hosting
1. **Click on your bucket name**
   - Opens bucket details page

2. **Go to Properties tab**
   - Click "Properties" tab at the top

3. **Scroll to Static website hosting**
   - Click "Edit" button

4. **Configure Settings**
   ```
   Static website hosting: Enable
   Hosting type: Host a static website
   Index document: index.html
   Error document: error.html (optional)
   ```

5. **Save Changes**
   - Click "Save changes"
   - Note the website endpoint URL displayed

**Validation Check:** You should see a website endpoint URL like: `http://your-bucket-name.s3-website-region.amazonaws.com`

### Step 3: Upload Frontend Files

#### Upload HTML File
1. **Go to Objects tab**
   - Click "Objects" tab in your bucket

2. **Click "Upload"**
   - Click the "Upload" button

3. **Add index.html**
   - Click "Add files"
   - Upload the `index.html` file from `src/frontend/` directory
   - Or create it directly (content provided below)

4. **Upload Additional Files**
   - Upload `style.css` and `script.js` files
   - These files are in the `src/frontend/` directory

5. **Set Permissions**
   - In the upload dialog, expand "Permissions"
   - Under "Predefined ACLs", select "Grant public-read access"
   - Check the acknowledgment box

6. **Complete Upload**
   - Click "Upload" button
   - Wait for upload completion

**Validation Check:** You should see all three files (index.html, style.css, script.js) in your bucket.

### Step 4: Configure Bucket Policy for Public Access

#### Create Bucket Policy
1. **Go to Permissions tab**
   - Click "Permissions" tab in your bucket

2. **Edit Bucket Policy**
   - Scroll to "Bucket policy"
   - Click "Edit"

3. **Add Policy JSON**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "PublicReadGetObject",
         "Effect": "Allow",
         "Principal": "*",
         "Action": "s3:GetObject",
         "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
       }
     ]
   }
   ```
   **Replace `YOUR-BUCKET-NAME` with your actual bucket name**

4. **Save Policy**
   - Click "Save changes"

**Validation Check:** Visit your website endpoint URL - you should see the frontend interface.

---

## Integrate SNS Notifications and Lambda Functions

### Step 1: Create SNS Topic

#### Access SNS Service
1. **Navigate to SNS**
   - In AWS Console search, type "SNS"
   - Click "Amazon Simple Notification Service"

#### Create Topic
1. **Click "Create topic"**
   - Orange button on SNS dashboard

2. **Configure Topic**
   ```
   Type: Standard
   Name: event-announcements
   Display name: Event Announcements
   ```

3. **Create Topic**
   - Click "Create topic"
   - Note the Topic ARN displayed

**Validation Check:** You should see your topic in the SNS topics list with an ARN like: `arn:aws:sns:region:account:event-announcements`

**⚠️ IMPORTANT:** Copy and save your SNS Topic ARN - you'll need it for the Lambda function configuration.

### Step 2: Add Subscribers to SNS Topic

#### Add Email Subscription
1. **Click on your topic name**
   - Opens topic details page

2. **Click "Create subscription"**
   - In the Subscriptions section

3. **Configure Email Subscription**
   ```
   Protocol: Email
   Endpoint: your-email@example.com
   ```

4. **Create Subscription**
   - Click "Create subscription"
   - Check your email and confirm subscription

#### Add SMS Subscription (Optional)
1. **Create another subscription**
   ```
   Protocol: SMS
   Endpoint: +1234567890 (your phone number with country code)
   ```

2. **Create Subscription**
   - SMS confirmation will be sent automatically

**Validation Check:** You should see confirmed subscriptions in your topic's subscription list.

### Step 3: Create IAM Role for Lambda

#### Access IAM Service
1. **Navigate to IAM**
   - Search "IAM" in AWS Console
   - Click "Identity and Access Management"

#### Create Role
1. **Click "Roles" in left sidebar**
2. **Click "Create role"**

3. **Configure Role**
   ```
   Trusted entity type: AWS service
   Use case: Lambda
   ```
   - Click "Next"

4. **Attach Policies**
   - Search and select these policies:
     - `AWSLambdaBasicExecutionRole`
     - `AmazonSNSFullAccess`
   - Click "Next"

5. **Name the Role**
   ```
   Role name: EventAnnouncementLambdaRole
   Description: Role for Lambda function to publish to SNS
   ```

6. **Create Role**
   - Click "Create role"

**Validation Check:** You should see the new role in your IAM roles list.

### Step 4: Create Lambda Function

#### Access Lambda Service
1. **Navigate to Lambda**
   - Search "Lambda" in AWS Console
   - Click "AWS Lambda"

#### Create Function
1. **Click "Create function"**
   - Orange button on Lambda dashboard

2. **Configure Function**
   ```
   Option: Author from scratch
   Function name: processEventAnnouncement
   Runtime: Python 3.9
   Architecture: x86_64
   ```

3. **Execution Role**
   - Choose "Use an existing role"
   - Select: `EventAnnouncementLambdaRole`

4. **Create Function**
   - Click "Create function"

**Validation Check:** You should see the Lambda function editor with a basic Python template.

### Step 5: Configure Lambda Function Code

#### Add Function Code
1. **In the Code tab**
   - Replace the default code with the content from `src/lambda/event-processor.py`

2. **Key Code Sections**
   ```python
   import json
   import boto3
   import logging
   from datetime import datetime

   # Initialize SNS client
   sns = boto3.client('sns')
   logger = logging.getLogger()
   logger.setLevel(logging.INFO)

   def lambda_handler(event, context):
       try:
           # Parse the incoming event
           body = json.loads(event['body'])
           
           # Extract event details
           event_title = body['title']
           event_description = body['description']
           event_date = body['date']
           
           # Create message
           message = f"""
           🎉 New Event Announcement!
           
           Title: {event_title}
           Description: {event_description}
           Date: {event_date}
           
           Don't miss out!
           """
           
           # Publish to SNS
           response = sns.publish(
               TopicArn='YOUR_SNS_TOPIC_ARN',
               Message=message,
               Subject=f'Event: {event_title}'
           )
           
           return {
               'statusCode': 200,
               'headers': {
                   'Access-Control-Allow-Origin': '*',
                   'Access-Control-Allow-Headers': 'Content-Type',
                   'Access-Control-Allow-Methods': 'POST, OPTIONS'
               },
               'body': json.dumps({
                   'message': 'Event announcement sent successfully',
                   'messageId': response['MessageId']
               })
           }
           
       except Exception as e:
           logger.error(f"Error processing event: {str(e)}")
           return {
               'statusCode': 500,
               'headers': {
                   'Access-Control-Allow-Origin': '*'
               },
               'body': json.dumps({
                   'error': 'Failed to process event announcement'
               })
           }
   ```

3. **Update SNS Topic ARN**
   - Replace `YOUR_SNS_TOPIC_ARN` with your actual SNS topic ARN from Step 1
   - Use the ARN you copied earlier (format: `arn:aws:sns:region:account:event-announcements`)

4. **Deploy Function**
   - Click "Deploy" button
   - Wait for deployment confirmation

**Validation Check:** The function should deploy successfully without errors.

### Step 6: Configure Lambda Environment Variables

#### Add Environment Variables
1. **Go to Configuration tab**
   - Click "Configuration" tab in Lambda console

2. **Click "Environment variables"**
   - In the left sidebar

3. **Add Variables**
   ```
   Key: SNS_TOPIC_ARN
   Value: arn:aws:sns:region:account:event-announcements
   ```

4. **Save Changes**
   - Click "Save"

**Validation Check:** Environment variable should appear in the list.

---

## Setup, Test and Deploy the API Gateway

### Step 1: Create API Gateway

#### Access API Gateway Service
1. **Navigate to API Gateway**
   - Search "API Gateway" in AWS Console
   - Click "Amazon API Gateway"

#### Create API
1. **Click "Create API"**
   - Choose "REST API" (not private)
   - Click "Build"

2. **Configure API**
   ```
   API name: event-announcement-api
   Description: API for event announcement system
   Endpoint Type: Regional
   ```

3. **Create API**
   - Click "Create API"

**Validation Check:** You should see the API Gateway console with your new API.

### Step 2: Create API Resources and Methods

#### Create Resource
1. **Click "Actions" dropdown**
   - Select "Create Resource"

2. **Configure Resource**
   ```
   Resource Name: events
   Resource Path: /events
   Enable API Gateway CORS: ✓ (checked)
   ```

3. **Create Resource**
   - Click "Create Resource"

#### Create POST Method
1. **Select /events resource**
   - Click on the `/events` resource

2. **Click "Actions" → "Create Method"**
   - Select "POST" from dropdown
   - Click the checkmark

3. **Configure Method**
   ```
   Integration type: Lambda Function
   Use Lambda Proxy integration: ✓ (checked)
   Lambda Region: [your region]
   Lambda Function: processEventAnnouncement
   ```

4. **Save Method**
   - Click "Save"
   - Click "OK" to grant permissions

#### Create GET Method (for retrieving events)
1. **Click "Actions" → "Create Method"**
   - Select "GET" from dropdown
   - Click the checkmark

2. **Configure Method**
   ```
   Integration type: Lambda Function
   Use Lambda Proxy integration: ✓ (checked)
   Lambda Region: [your region]
   Lambda Function: processEventAnnouncement
   ```

3. **Save Method**
   - Click "Save"
   - Click "OK" to grant permissions

#### Create OPTIONS Method (for CORS)
1. **Click "Actions" → "Create Method"**
   - Select "OPTIONS"
   - Click checkmark

2. **Configure OPTIONS**
   ```
   Integration type: Mock
   ```

3. **Save Method**
   - Click "Save"

**Validation Check:** You should see POST, GET, and OPTIONS methods under the /events resource.

### Step 3: Configure CORS

#### Enable CORS
1. **Select /events resource**
2. **Click "Actions" → "Enable CORS"**

3. **Configure CORS Settings**
   ```
   Access-Control-Allow-Origin: *
   Access-Control-Allow-Headers: Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token
   Access-Control-Allow-Methods: GET,POST,OPTIONS
   ```

4. **Enable CORS**
   - Click "Enable CORS and replace existing CORS headers"
   - Click "Yes, replace existing values"

**Validation Check:** CORS should be enabled for all methods.

### Step 4: Deploy API

#### Create Deployment
1. **Click "Actions" → "Deploy API"**

2. **Configure Deployment**
   ```
   Deployment stage: [New Stage]
   Stage name: prod
   Stage description: Production stage
   Deployment description: Initial deployment
   ```

3. **Deploy**
   - Click "Deploy"

**Validation Check:** You should see the API endpoint URL like: `https://api-id.execute-api.region.amazonaws.com/prod`

### Step 5: Test API Gateway

#### Test POST Method
1. **Click on POST method under /events**
2. **Click "TEST" button**

3. **Configure Test**
   ```
   Request Body:
   {
     "title": "Test Event",
     "description": "This is a test event announcement",
     "date": "2024-12-25"
   }
   ```

4. **Run Test**
   - Click "Test" button
   - Check response status and body

#### Test GET Method
1. **Click on GET method under /events**
2. **Click "TEST" button**
3. **Run Test**
   - Click "Test" button (no request body needed)
   - Check response status and body

**Validation Check:** Both tests should return 200 status code with appropriate response data.

---

## Test and Finalize

### Step 1: Update Frontend Configuration

#### Update API Endpoint
1. **Edit script.js file**
   - In your S3 bucket, download `script.js`
   - Update the API endpoint URL:
   ```javascript
   const API_ENDPOINT = 'https://your-api-id.execute-api.region.amazonaws.com/prod/events';
   ```

2. **Re-upload to S3**
   - Upload the updated file to your S3 bucket
   - Ensure public read access

**Validation Check:** The frontend should now connect to your API.

### Step 2: End-to-End Testing

#### Test Complete Flow
1. **Open your website**
   - Visit your S3 website endpoint URL

2. **Create Test Event**
   ```
   Event Title: Welcome Party
   Event Description: Join us for a welcome party for new team members
   Event Date: 2024-12-20
   ```

3. **Submit Event**
   - Click "Send Announcement" button
   - Check for success message

4. **Verify Notifications**
   - Check your email for the announcement
   - Check SMS if configured
   - Verify message content and formatting

**Validation Check:** You should receive notifications via all configured channels.

### Step 3: Monitor and Verify

#### Check CloudWatch Logs
1. **Navigate to CloudWatch**
   - Search "CloudWatch" in AWS Console

2. **View Lambda Logs**
   - Go to "Log groups"
   - Find `/aws/lambda/processEventAnnouncement`
   - Check recent log entries

3. **Verify Execution**
   - Look for successful execution logs
   - Check for any error messages

#### Check SNS Metrics
1. **Go to SNS Console**
2. **Click on your topic**
3. **View "Monitoring" tab**
   - Check message publication metrics
   - Verify delivery statistics

**Validation Check:** Logs should show successful execution and message delivery.

### Step 4: Performance Testing

#### Load Testing (Optional)
1. **Test Multiple Requests**
   - Send several announcements quickly
   - Verify all are processed

2. **Check Response Times**
   - Monitor API Gateway metrics
   - Verify Lambda execution duration

**Validation Check:** System should handle multiple concurrent requests efficiently.

---

## Project Conclusion and Clean-up

### Step 1: Document Your Implementation

#### Create Documentation
1. **API Documentation**
   - Document API endpoints and request/response formats
   - Include example requests and responses

2. **Architecture Documentation**
   - Document the complete system architecture
   - Include service interactions and data flow

### Step 2: Security Review

#### Review Security Settings
1. **IAM Permissions**
   - Verify least privilege access
   - Remove unnecessary permissions

2. **API Security**
   - Consider adding API keys or authentication
   - Review CORS settings

3. **S3 Security**
   - Verify bucket policy is appropriate
   - Consider CloudFront for better security

### Step 3: Cost Optimization

#### Review Resource Usage
1. **Lambda Configuration**
   - Optimize memory allocation
   - Set appropriate timeout values

2. **API Gateway**
   - Monitor request patterns
   - Consider caching if appropriate

### Step 4: Clean-up (Optional)

#### Remove Resources
If you want to clean up the project:

1. **Delete S3 Bucket**
   - Empty bucket contents first
   - Then delete the bucket

2. **Delete Lambda Function**
   - Go to Lambda console
   - Delete the function

3. **Delete API Gateway**
   - Go to API Gateway console
   - Delete the API

4. **Delete SNS Topic**
   - Go to SNS console
   - Delete the topic and subscriptions

5. **Delete IAM Role**
   - Go to IAM console
   - Delete the Lambda execution role

**Note:** Only perform cleanup if you no longer need the project for your portfolio.

---

## Quick Setup Checklist

For experienced users, here's a condensed checklist:

### Infrastructure Setup (15 minutes)
- [ ] Create S3 bucket with static website hosting
- [ ] Upload frontend files with public read access
- [ ] Create SNS topic and add email/SMS subscriptions
- [ ] Create IAM role for Lambda with SNS permissions
- [ ] Create Lambda function with event processing code
- [ ] Update Lambda code with correct SNS topic ARN

### API Configuration (10 minutes)
- [ ] Create API Gateway REST API
- [ ] Create /events resource with POST and OPTIONS methods
- [ ] Configure Lambda integration and CORS
- [ ] Deploy API to production stage
- [ ] Test API endpoint

### Integration & Testing (10 minutes)
- [ ] Update frontend with API endpoint URL
- [ ] Test end-to-end flow
- [ ] Verify notifications are received
- [ ] Check CloudWatch logs for errors
- [ ] Document API endpoints and usage

### Total Time: ~35 minutes

---

## Troubleshooting Common Issues

### Lambda Function Issues
- **Timeout errors**: Increase timeout in Lambda configuration
- **Permission errors**: Verify IAM role has SNS permissions
- **Import errors**: Check Python runtime version compatibility

### API Gateway Issues
- **CORS errors**: Verify CORS is properly configured
- **404 errors**: Check resource paths and deployment stage
- **Integration errors**: Verify Lambda function name and region

### SNS Issues
- **Delivery failures**: Check subscription confirmations
- **Permission errors**: Verify topic permissions and IAM roles
- **Message formatting**: Check message content and encoding

### S3 Website Issues
- **403 Forbidden**: Check bucket policy and object permissions
- **404 Not Found**: Verify index.html exists and is public
- **HTTPS issues**: Use HTTP endpoint for S3 static websites

For detailed troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

---

**Congratulations!** 🎉 You've successfully built and deployed a serverless event announcement system using AWS services. This project demonstrates your ability to work with multiple AWS services and build scalable, cost-effective solutions.
