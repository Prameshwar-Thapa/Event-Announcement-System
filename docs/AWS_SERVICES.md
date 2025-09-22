# AWS Services Deep Dive: Event Announcement System

## Table of Contents
1. [Serverless Computing in AWS](#1-serverless-computing-in-aws)
2. [Event-Driven Architecture](#2-event-driven-architecture)
3. [Amazon S3 (Simple Storage Service)](#3-amazon-s3-simple-storage-service)
4. [AWS Lambda](#4-aws-lambda)
5. [Amazon API Gateway](#5-amazon-api-gateway)
6. [Amazon SNS (Simple Notification Service)](#6-amazon-sns-simple-notification-service)
7. [Monitoring and Observability](#7-monitoring-and-observability)

---

## 1. Serverless Computing in AWS

### What is Serverless?

**Serverless computing** is a cloud execution model where the cloud provider (AWS) automatically manages the infrastructure, scaling, and server provisioning. You only focus on writing code without worrying about servers.

### Key Characteristics:
- **No Server Management**: AWS handles all infrastructure
- **Automatic Scaling**: Scales from zero to thousands of requests
- **Pay-per-Use**: Only pay when your code runs
- **Event-Driven**: Triggered by events (HTTP requests, file uploads, etc.)
- **Stateless**: Each execution is independent

### How Serverless Works:

```
Event Trigger → AWS Provisions Resources → Code Executes → Resources Released
```

1. **Event Occurs**: HTTP request, file upload, scheduled event
2. **AWS Provisions**: Automatically allocates compute resources
3. **Code Executes**: Your function runs in a managed container
4. **Cleanup**: Resources are released after execution
5. **Billing**: You're charged only for execution time

### Why Serverless is Growing:

#### **Business Benefits:**
- **Cost Efficiency**: 60-70% cost reduction compared to traditional servers
- **Faster Time-to-Market**: Focus on business logic, not infrastructure
- **Automatic Scaling**: Handles traffic spikes without manual intervention
- **Reduced Operational Overhead**: No server patching, maintenance, or monitoring

#### **Technical Benefits:**
- **High Availability**: Built-in redundancy across multiple availability zones
- **Security**: AWS manages security patches and updates
- **Performance**: Cold start optimizations and regional deployment
- **Integration**: Native integration with 200+ AWS services

#### **Market Growth:**
- **Developer Productivity**: 40% faster development cycles
- **Microservices Architecture**: Perfect for breaking monoliths
- **Edge Computing**: Functions run closer to users globally
- **AI/ML Integration**: Easy integration with AWS AI services

### Serverless in Our Project:
```
User Request → API Gateway → Lambda Function → SNS → Email/SMS
     ↓              ↓           ↓         ↓
Static Website → REST API → Processing → Delivery
```

---

## 2. Event-Driven Architecture

### What is Event-Driven Architecture?

**Event-Driven Architecture (EDA)** is a software design pattern where components communicate through events. When something happens (an event), it triggers actions in other parts of the system.

### Core Concepts:

#### **Event**: 
A significant change in state or occurrence
- Example: "User submitted event announcement form"

#### **Event Producer**: 
Component that generates events
- Example: Frontend form submission

#### **Event Consumer**: 
Component that responds to events
- Example: Lambda function processing the event

#### **Event Router**: 
Directs events to appropriate consumers
- Example: API Gateway routing requests

### How Event-Driven Systems Work:

```
Event Producer → Event Router → Event Consumer → Action
```

1. **Event Generation**: Something happens in the system
2. **Event Publishing**: Event is sent to an event router
3. **Event Routing**: Router determines which consumers should receive the event
4. **Event Processing**: Consumers process the event and take action
5. **Response/Notification**: Results are communicated back or to other systems

### Benefits of Event-Driven Architecture:

#### **Scalability:**
- Components scale independently
- Handles varying loads automatically
- No bottlenecks from synchronous processing

#### **Flexibility:**
- Loose coupling between components
- Easy to add new features without changing existing code
- Components can be developed and deployed independently

#### **Reliability:**
- Fault isolation - one component failure doesn't crash the system
- Retry mechanisms for failed events
- Event persistence for reliability

#### **Real-time Processing:**
- Immediate response to events
- Real-time notifications and updates
- Better user experience

### Event-Driven Architecture in Our Project:

#### **Event Flow:**
```
1. User Action (Event Producer)
   ↓
2. Form Submission (Event)
   ↓
3. API Gateway (Event Router)
   ↓
4. Lambda Function (Event Consumer)
   ↓
5. SNS Publishing (Event Producer)
   ↓
6. Email/SMS Delivery (Event Consumers)
```

#### **Detailed Event Chain:**

**Event 1: Form Submission**
- **Producer**: Frontend JavaScript
- **Event**: HTTP POST request with event data
- **Consumer**: API Gateway

**Event 2: API Request**
- **Producer**: API Gateway
- **Event**: Lambda invocation with request data
- **Consumer**: Lambda function

**Event 3: SNS Publication**
- **Producer**: Lambda function
- **Event**: SNS message publication
- **Consumer**: SNS subscribers (email/SMS endpoints)

**Event 4: Notification Delivery**
- **Producer**: SNS service
- **Event**: Message delivery to endpoints
- **Consumer**: Email servers, SMS gateways

#### **Event Data Structure:**
```json
{
  "eventType": "announcement_created",
  "timestamp": "2024-12-15T10:00:00Z",
  "data": {
    "title": "Team Meeting",
    "description": "Weekly team sync",
    "date": "2024-12-20",
    "time": "14:00",
    "location": "Conference Room A"
  },
  "metadata": {
    "source": "web_form",
    "requestId": "abc-123-def"
  }
}
```

### Advantages in Our Implementation:

1. **Asynchronous Processing**: Form submission doesn't wait for email delivery
2. **Scalable Notifications**: Can handle thousands of subscribers
3. **Fault Tolerance**: If email fails, SMS can still work
4. **Extensibility**: Easy to add new notification channels
5. **Monitoring**: Each event can be logged and monitored

---

## 3. Amazon S3 (Simple Storage Service)

### What is Amazon S3?

**Amazon S3** is a highly scalable, durable, and secure object storage service. It's designed to store and retrieve any amount of data from anywhere on the web.

### Core Concepts:

#### **Objects:**
- Files stored in S3 (HTML, CSS, JS, images, videos, etc.)
- Each object has data, metadata, and a unique key
- Size: 0 bytes to 5TB per object

#### **Buckets:**
- Containers that hold objects
- Globally unique names
- Regional resources (data stays in chosen region)
- Unlimited storage capacity

#### **Keys:**
- Unique identifier for objects within a bucket
- Example: `frontend/index.html`, `assets/logo.png`

### What is an S3 Bucket?

An **S3 bucket** is like a top-level folder that:
- Contains all your objects (files)
- Has a globally unique name across all AWS accounts
- Exists in a specific AWS region
- Can host static websites
- Has configurable permissions and policies

### S3 Bucket Structure in Our Project:
```
event-announcements-frontend-js-12345/
├── index.html          (Main webpage)
├── style.css           (Styling)
├── script.js           (Frontend logic)
└── assets/             (Optional: images, icons)
```

### Security Features Used in Our Project:

#### **1. Bucket Policy**
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

**What it does:**
- **Effect: Allow**: Grants permission
- **Principal: "*"**: Anyone can access
- **Action: s3:GetObject**: Only read access (no write/delete)
- **Resource**: Applies to all objects in the bucket

#### **2. Public Access Settings**
- **Block Public Access**: Disabled for website hosting
- **Public Read Access**: Enabled for web files
- **Granular Control**: Only GET requests allowed

#### **3. Access Control Lists (ACLs)**
- **Object-level permissions**: Each file can have specific permissions
- **Public-read**: Files are readable by anyone
- **No write access**: Prevents unauthorized modifications

#### **4. HTTPS Enforcement**
- **Secure connections**: All data transfer encrypted
- **SSL/TLS**: Protects data in transit
- **Certificate management**: AWS handles SSL certificates

### How S3 Works as Static Website Hosting:

#### **Traditional Web Hosting vs S3:**

**Traditional Hosting:**
```
User Request → Web Server → Database → Dynamic Content → Response
```

**S3 Static Hosting:**
```
User Request → S3 Bucket → Static Files → Direct Response
```

#### **S3 Static Website Features:**

**1. Website Endpoint:**
- Format: `http://bucket-name.s3-website-region.amazonaws.com`
- Direct access to your website
- No server management required

**2. Index Document:**
- Default file served when accessing the root URL
- Usually `index.html`
- Automatically served for directory requests

**3. Error Document:**
- Custom error pages (404, 403, etc.)
- Better user experience
- Professional error handling

**4. Routing Rules:**
- Redirect requests to different pages
- Handle URL patterns
- SEO-friendly URLs

#### **Benefits of S3 Static Hosting:**

**Cost-Effective:**
- $0.023 per GB storage
- $0.0004 per 1,000 GET requests
- No server costs or maintenance

**Highly Available:**
- 99.999999999% (11 9's) durability
- 99.99% availability SLA
- Automatic redundancy across multiple facilities

**Scalable:**
- Handles millions of requests
- Global content delivery with CloudFront
- No capacity planning needed

**Secure:**
- Encryption at rest and in transit
- Fine-grained access controls
- Integration with AWS security services

### S3 Configuration in Our Project:

#### **Step-by-Step Setup:**

**1. Bucket Creation:**
```bash
# Bucket naming convention
event-announcements-frontend-[initials]-[random-number]
# Example: event-announcements-frontend-js-12345
```

**2. Static Website Configuration:**
```json
{
  "IndexDocument": {
    "Suffix": "index.html"
  },
  "ErrorDocument": {
    "Key": "error.html"
  }
}
```

**3. File Upload with Permissions:**
- Upload HTML, CSS, JS files
- Set public-read permissions
- Verify file accessibility

**4. Website Testing:**
- Access website endpoint URL
- Test all functionality
- Verify responsive design

### Integration with Other Services:

#### **S3 → API Gateway:**
- Frontend JavaScript makes API calls
- CORS configuration allows cross-origin requests
- Secure communication with backend services

#### **S3 → CloudFront (Optional Enhancement):**
- Global content delivery network
- Faster loading times worldwide
- Additional security features
- Custom domain support

---
#### **Detailed Code Analysis:**

**Lines 1-5: Import Statements**
```python
import json          # JSON parsing and formatting
import boto3         # AWS SDK for Python
import logging       # Logging functionality
from datetime import datetime  # Date/time operations
import os           # Environment variable access
```
- **json**: Handles request/response data parsing
- **boto3**: AWS SDK for interacting with SNS service
- **logging**: Structured logging for debugging and monitoring
- **datetime**: Date validation and timestamp generation
- **os**: Access to environment variables (SNS Topic ARN)

**Lines 7-10: Service Initialization**
```python
# Initialize AWS services
sns = boto3.client('sns')    # SNS client for sending notifications
logger = logging.getLogger() # Logger instance
logger.setLevel(logging.INFO) # Set logging level
```
- **sns client**: Global SNS client for publishing messages
- **logger setup**: Configures logging for CloudWatch integration
- **INFO level**: Captures important events without debug noise

**Lines 12-31: Main Handler Function**
```python
def lambda_handler(event, context):
```
- **event**: Contains request data from API Gateway
- **context**: Lambda runtime information (request ID, memory, etc.)
- **Return**: HTTP response object with status code, headers, and body

**Lines 33-35: Event Logging**
```python
logger.info(f"Received event: {json.dumps(event)}")
```
- **Purpose**: Debug incoming requests
- **CloudWatch**: Logs appear in CloudWatch Logs
- **Security**: Helps troubleshoot issues

**Lines 37-38: HTTP Method Detection**
```python
http_method = event.get('httpMethod', 'POST')
```
- **API Gateway Integration**: Extracts HTTP method from event
- **Default**: Falls back to POST if not specified
- **Routing**: Determines which handler function to call

**Lines 40-42: CORS Preflight Handling**
```python
if http_method == 'OPTIONS':
    return create_cors_response(200, '')
```
- **CORS**: Cross-Origin Resource Sharing support
- **Preflight**: Browser sends OPTIONS before actual request
- **Response**: Returns appropriate CORS headers

**Lines 44-50: Request Routing**
```python
if http_method == 'GET':
    return handle_get_events(event)
if http_method == 'POST':
    return handle_post_event(event)
```
- **GET**: Retrieve existing events (future enhancement)
- **POST**: Create and send new event announcements
- **Separation**: Clean code organization

**Lines 52-58: Error Handling**
```python
except Exception as e:
    logger.error(f"Unexpected error: {str(e)}")
    return create_error_response(500, "Internal server error occurred")
```
- **Global Exception Handler**: Catches unexpected errors
- **Logging**: Records errors for debugging
- **User-Friendly**: Returns generic error message

**Lines 60-85: GET Handler Function**
```python
def handle_get_events(event):
```
- **Purpose**: Return list of recent events
- **Demo Data**: Returns sample events (would connect to database in production)
- **Response Format**: Consistent JSON structure

**Lines 87-155: POST Handler Function**
```python
def handle_post_event(event):
```

**Lines 89-93: Request Body Parsing**
```python
if 'body' not in event:
    raise ValueError("Request body is missing")
body = json.loads(event['body'])
```
- **Validation**: Ensures request has body
- **JSON Parsing**: Converts string to Python dictionary
- **Error Handling**: Raises exception for invalid JSON

**Lines 95-100: Field Validation**
```python
required_fields = ['title', 'description', 'date']
for field in required_fields:
    if field not in body or not body[field].strip():
        raise ValueError(f"Missing or empty required field: {field}")
```
- **Required Fields**: Ensures essential data is present
- **Strip**: Removes whitespace
- **Validation**: Prevents empty or missing fields

**Lines 102-108: Data Extraction**
```python
event_title = body['title'].strip()
event_description = body['description'].strip()
event_date = body['date'].strip()
event_time = body.get('time', '').strip()
event_location = body.get('location', '').strip()
```
- **Required Fields**: title, description, date
- **Optional Fields**: time, location
- **Data Cleaning**: Strip whitespace from all fields

**Lines 110-115: Date Validation**
```python
try:
    datetime.strptime(event_date, '%Y-%m-%d')
except ValueError:
    raise ValueError("Invalid date format. Use YYYY-MM-DD")
```
- **Format Validation**: Ensures date is in YYYY-MM-DD format
- **Error Handling**: Provides clear error message
- **Data Integrity**: Prevents invalid dates

**Lines 117-135: Message Formatting**
```python
message_parts = [
    "🎉 NEW EVENT ANNOUNCEMENT 🎉",
    "",
    f"📅 Event: {event_title}",
    f"📝 Description: {event_description}",
    f"📆 Date: {event_date}"
]
```
- **Template**: Consistent message format
- **Emojis**: Visual appeal for notifications
- **Dynamic Content**: Includes user-provided data
- **Optional Fields**: Added conditionally

**Lines 137-143: Environment Configuration**
```python
topic_arn = os.environ.get('SNS_TOPIC_ARN')
if not topic_arn:
    topic_arn = 'arn:aws:sns:us-east-1:123456789012:event-announcements'
    logger.warning("SNS_TOPIC_ARN environment variable not set, using fallback")
```
- **Environment Variable**: Configurable SNS Topic ARN
- **Fallback**: Default ARN for development
- **Best Practice**: Externalized configuration

**Lines 145-149: Subject Line Creation**
```python
subject = f"Event Announcement: {event_title}"
if event_date:
    subject += f" - {event_date}"
```
- **Email Subject**: Clear, descriptive subject line
- **Dynamic**: Includes event title and date
- **Professional**: Consistent format

**Lines 151-158: SNS Publishing**
```python
response = sns.publish(
    TopicArn=topic_arn,
    Message=message,
    Subject=subject
)
message_id = response['MessageId']
```
- **SNS Publish**: Sends message to all subscribers
- **Parameters**: Topic ARN, message content, subject
- **Response**: Contains message ID for tracking

**Lines 160-168: Success Response**
```python
return create_cors_response(200, json.dumps({
    'success': True,
    'message': 'Event announcement sent successfully!',
    'messageId': message_id,
    'eventTitle': event_title,
    'timestamp': datetime.utcnow().isoformat() + 'Z'
}))
```
- **HTTP 200**: Success status code
- **JSON Response**: Structured response data
- **Message ID**: For tracking and debugging
- **Timestamp**: ISO format timestamp

**Lines 170-185: Error Handling**
```python
except json.JSONDecodeError as e:
    return create_error_response(400, "Invalid JSON format in request body")
except ValueError as e:
    return create_error_response(400, str(e))
except Exception as e:
    return create_error_response(500, "Internal server error occurred")
```
- **Specific Exceptions**: Different error types handled appropriately
- **HTTP Status Codes**: 400 for client errors, 500 for server errors
- **Error Messages**: User-friendly error descriptions

**Lines 187-197: CORS Response Helper**
```python
def create_cors_response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
            'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
            'Content-Type': 'application/json'
        },
        'body': body
    }
```
- **CORS Headers**: Enable cross-origin requests from frontend
- **Allow-Origin**: Permits requests from any domain
- **Allow-Methods**: Specifies supported HTTP methods
- **Content-Type**: Indicates JSON response format

### Lambda Performance Optimization:

#### **Cold Start Optimization:**
- **Global Variables**: SNS client initialized outside handler
- **Connection Reuse**: Boto3 clients reused across invocations
- **Minimal Dependencies**: Only necessary imports

#### **Memory Configuration:**
- **128MB**: Sufficient for our lightweight function
- **CPU Scaling**: CPU power scales with memory allocation
- **Cost Optimization**: Lower memory = lower cost

#### **Timeout Configuration:**
- **30 seconds**: Adequate for SNS publishing
- **Error Prevention**: Prevents hanging requests
- **Cost Control**: Limits maximum execution time

### Lambda Monitoring and Logging:

#### **CloudWatch Integration:**
- **Automatic Logging**: All print/logger statements go to CloudWatch
- **Log Groups**: `/aws/lambda/processEventAnnouncement`
- **Retention**: Configurable log retention period

#### **Metrics Available:**
- **Invocations**: Number of function executions
- **Duration**: Execution time per invocation
- **Errors**: Failed executions
- **Throttles**: Rate limiting events

#### **Custom Metrics:**
```python
logger.info(f"Successfully published message with ID: {message_id}")
```
- **Structured Logging**: Consistent log format
- **Searchable**: Easy to query in CloudWatch Logs
- **Debugging**: Helps troubleshoot issues

---

## 5. Amazon API Gateway

### What is Amazon API Gateway?

**Amazon API Gateway** is a fully managed service that makes it easy to create, publish, maintain, monitor, and secure APIs at any scale. It acts as a "front door" for applications to access data, business logic, or functionality from backend services.

### Core Concepts:

#### **API (Application Programming Interface):**
- Contract between different software components
- Defines how applications communicate
- Specifies request/response formats and protocols

#### **REST API:**
- **Representational State Transfer**
- Architectural style for web services
- Uses standard HTTP methods (GET, POST, PUT, DELETE)
- Stateless communication
- Resource-based URLs

#### **Gateway Pattern:**
- Single entry point for all client requests
- Routes requests to appropriate backend services
- Handles cross-cutting concerns (authentication, logging, rate limiting)

### How API Gateway Works:

```
Client Request → API Gateway → Backend Service → Response → API Gateway → Client
```

#### **Request Flow:**
1. **Client Request**: Frontend sends HTTP request
2. **Gateway Processing**: API Gateway receives and validates request
3. **Authentication**: Verifies client permissions (if configured)
4. **Routing**: Determines which backend service to call
5. **Integration**: Invokes backend service (Lambda, HTTP endpoint, AWS service)
6. **Response Processing**: Formats and returns response to client

### What is REST API?

**REST (Representational State Transfer)** is an architectural style for designing web services that use standard HTTP methods and status codes.

#### **REST Principles:**

**1. Stateless:**
- Each request contains all information needed to process it
- Server doesn't store client context between requests
- Improves scalability and reliability

**2. Resource-Based:**
- Everything is treated as a resource
- Resources identified by URLs
- Example: `/events` represents event resources

**3. HTTP Methods:**
- **GET**: Retrieve data (read-only)
- **POST**: Create new resources
- **PUT**: Update existing resources
- **DELETE**: Remove resources
- **OPTIONS**: Get allowed methods (CORS)

**4. Uniform Interface:**
- Consistent way to interact with resources
- Standard HTTP status codes
- Predictable URL patterns

#### **REST API Benefits:**
- **Simplicity**: Easy to understand and implement
- **Scalability**: Stateless nature supports horizontal scaling
- **Flexibility**: Platform and language independent
- **Caching**: HTTP caching mechanisms work naturally
- **Tooling**: Extensive tooling and framework support

### API Gateway Components in Our Project:

#### **1. API Structure:**
```
event-announcement-api (REST API)
└── /events (Resource)
    ├── GET (Method)
    ├── POST (Method)
    └── OPTIONS (Method)
```

#### **2. Resource: `/events`**

**What is a Resource?**
- Represents a collection or entity in your API
- Maps to a URL path
- Can have multiple HTTP methods
- Hierarchical structure possible

**Our `/events` Resource:**
- **Purpose**: Manages event announcements
- **URL**: `https://api-id.execute-api.region.amazonaws.com/prod/events`
- **Methods**: GET, POST, OPTIONS

#### **3. Methods Explained:**

**POST Method:**
- **Purpose**: Create new event announcements
- **Request Body**: JSON with event details
- **Integration**: Lambda function
- **Response**: Success/error message with message ID

```json
POST /events
Content-Type: application/json

{
  "title": "Team Meeting",
  "description": "Weekly team sync",
  "date": "2024-12-20",
  "time": "14:00",
  "location": "Conference Room A"
}
```

**GET Method:**
- **Purpose**: Retrieve existing event announcements
- **Request Body**: None
- **Integration**: Lambda function
- **Response**: List of events

```json
GET /events

Response:
{
  "success": true,
  "events": [...],
  "count": 2
}
```

**OPTIONS Method:**
- **Purpose**: CORS preflight requests
- **Integration**: Mock integration (no backend call)
- **Response**: CORS headers
- **Browser Behavior**: Automatically sent before actual requests

#### **4. Integration Types:**

**Lambda Proxy Integration:**
- **Full Request**: Lambda receives complete HTTP request
- **Full Response**: Lambda returns complete HTTP response
- **Flexibility**: Lambda handles all request/response processing
- **Headers**: Lambda manages CORS headers

**Configuration:**
```json
{
  "type": "AWS_PROXY",
  "httpMethod": "POST",
  "uri": "arn:aws:apigateway:region:lambda:path/2015-03-31/functions/arn:aws:lambda:region:account:function:processEventAnnouncement/invocations"
}
```

#### **5. CORS (Cross-Origin Resource Sharing):**

**What is CORS?**
- Security feature implemented by web browsers
- Prevents websites from making requests to different domains
- API Gateway must explicitly allow cross-origin requests

**CORS Headers in Our Project:**
```http
Access-Control-Allow-Origin: *
Access-Control-Allow-Headers: Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token
Access-Control-Allow-Methods: GET,POST,OPTIONS
```

**Why CORS is Needed:**
- Frontend hosted on S3: `http://bucket-name.s3-website-region.amazonaws.com`
- API hosted on API Gateway: `https://api-id.execute-api.region.amazonaws.com`
- Different domains = CORS required

**CORS Flow:**
```
1. Browser sends OPTIONS request (preflight)
2. API Gateway returns CORS headers
3. Browser sends actual request (GET/POST)
4. API Gateway processes request and returns response with CORS headers
```

#### **6. Deployment Stages:**

**What are Stages?**
- Named references to deployments
- Allow multiple versions of API
- Different configurations per stage

**Our Stage Configuration:**
- **Stage Name**: `prod`
- **Description**: Production deployment
- **URL**: `https://api-id.execute-api.region.amazonaws.com/prod`

**Stage Benefits:**
- **Environment Separation**: dev, staging, prod
- **Version Control**: Multiple API versions
- **Configuration**: Different settings per stage
- **Rollback**: Easy to revert to previous versions

### API Gateway Features Used:

#### **1. Request Validation:**
- **Content-Type**: Ensures JSON requests
- **Required Fields**: Validated in Lambda function
- **Error Responses**: Proper HTTP status codes

#### **2. Error Handling:**
- **4xx Errors**: Client errors (bad request, validation)
- **5xx Errors**: Server errors (Lambda failures)
- **Custom Messages**: User-friendly error descriptions

#### **3. Logging and Monitoring:**
- **CloudWatch Logs**: Request/response logging
- **Metrics**: Request count, latency, errors
- **X-Ray Tracing**: Request tracing (optional)

#### **4. Security Features:**
- **HTTPS Only**: All communication encrypted
- **IAM Integration**: Role-based access control
- **API Keys**: Rate limiting and access control (optional)
- **CORS**: Controlled cross-origin access

### API Gateway Request/Response Flow:

#### **Successful POST Request:**
```
1. Frontend JavaScript:
   fetch('https://api-id.execute-api.region.amazonaws.com/prod/events', {
     method: 'POST',
     headers: { 'Content-Type': 'application/json' },
     body: JSON.stringify({ title: 'Event', description: '...', date: '2024-12-20' })
   })

2. API Gateway:
   - Receives HTTP POST request
   - Validates request format
   - Invokes Lambda function with proxy integration

3. Lambda Function:
   - Processes event data
   - Publishes to SNS
   - Returns success response

4. API Gateway:
   - Receives Lambda response
   - Adds CORS headers
   - Returns HTTP 200 with JSON body

5. Frontend JavaScript:
   - Receives response
   - Updates UI with success message
```

#### **Error Handling Flow:**
```
1. Invalid Request (missing required field):
   Frontend → API Gateway → Lambda → Validation Error → 400 Response

2. Lambda Function Error:
   Frontend → API Gateway → Lambda → Exception → 500 Response

3. SNS Publishing Error:
   Frontend → API Gateway → Lambda → SNS Error → 500 Response
```

### API Gateway Performance and Scaling:

#### **Automatic Scaling:**
- **Concurrent Requests**: Up to 10,000 concurrent requests per region
- **Rate Limiting**: 10,000 requests per second per account
- **Burst Capacity**: 5,000 requests per second burst
- **Regional**: Scales within AWS region

#### **Caching (Optional Enhancement):**
- **Response Caching**: Cache GET responses
- **TTL Configuration**: Time-to-live settings
- **Cache Keys**: Based on request parameters
- **Cost Optimization**: Reduces Lambda invocations

#### **Performance Optimization:**
- **Regional Endpoints**: Lower latency
- **Compression**: Automatic response compression
- **Connection Reuse**: HTTP keep-alive
- **Edge Optimization**: CloudFront integration (optional)

### API Gateway Pricing:

#### **Request-Based Pricing:**
- **REST API**: $3.50 per million requests
- **Data Transfer**: $0.09 per GB out
- **Caching**: Additional cost if enabled
- **Free Tier**: 1 million requests per month for 12 months

#### **Cost in Our Project:**
- **Low Volume**: Likely within free tier
- **Moderate Usage**: $1-5 per month
- **High Volume**: Scales linearly with requests

---
## 6. Amazon SNS (Simple Notification Service)

### What is Amazon SNS?

**Amazon Simple Notification Service (SNS)** is a fully managed messaging service that enables you to decouple microservices, distributed systems, and serverless applications. It provides a publish-subscribe (pub-sub) messaging pattern for high-throughput, push-based, many-to-many messaging.

### Core Concepts:

#### **Publisher-Subscriber Pattern:**
```
Publisher → Topic → Multiple Subscribers
```
- **Publisher**: Sends messages to a topic
- **Topic**: Communication channel for messages
- **Subscribers**: Receive messages from topics they're subscribed to

#### **Topics:**
- **Communication Channel**: Named access point for sending messages
- **Fan-Out**: One message sent to multiple subscribers
- **Durable**: Messages are stored redundantly across multiple servers
- **Regional**: Topics exist within specific AWS regions

#### **Subscriptions:**
- **Endpoint Registration**: How subscribers receive messages
- **Protocol Support**: Email, SMS, HTTP/HTTPS, Lambda, SQS
- **Filtering**: Subscribers can filter messages based on attributes
- **Confirmation**: Subscriptions must be confirmed by subscribers

### How SNS Works in Our Project:

#### **Architecture Flow:**
```
Lambda Function → SNS Topic → Email Subscribers
                            → SMS Subscribers
```

#### **Detailed Process:**

**1. Message Publishing:**
```python
response = sns.publish(
    TopicArn='arn:aws:sns:us-east-1:142595748980:event-announcements',
    Message=message,
    Subject=subject
)
```

**2. Message Distribution:**
- SNS receives the message
- Identifies all confirmed subscriptions
- Delivers message to each subscriber endpoint
- Handles delivery retries and failures

**3. Delivery Protocols:**

**Email Delivery:**
- **Protocol**: Email
- **Endpoint**: Email address (e.g., user@example.com)
- **Format**: Plain text or JSON
- **Confirmation**: Email confirmation required

**SMS Delivery:**
- **Protocol**: SMS
- **Endpoint**: Phone number with country code (+1234567890)
- **Format**: Plain text only
- **Confirmation**: Automatic confirmation

### SNS Topic Configuration:

#### **Topic Details:**
- **Name**: `event-announcements`
- **Type**: Standard (not FIFO)
- **ARN**: `arn:aws:sns:us-east-1:142595748980:event-announcements`
- **Region**: us-east-1

#### **Topic Attributes:**
```json
{
  "DisplayName": "Event Announcements",
  "DeliveryPolicy": {
    "default": {
      "healthyRetryPolicy": {
        "numRetries": 3,
        "minDelayTarget": 20,
        "maxDelayTarget": 20
      }
    }
  }
}
```

### Message Structure:

#### **Message Components:**

**1. Message Body:**
```text
🎉 NEW EVENT ANNOUNCEMENT 🎉

📅 Event: Team Building Workshop
📝 Description: Interactive workshop to strengthen team collaboration
📆 Date: 2024-12-22
🕐 Time: 14:00
📍 Location: Training Room B

Don't miss out on this exciting event!

---
This is an automated notification from the Event Announcement System
```

**2. Subject Line:**
```text
Event Announcement: Team Building Workshop - 2024-12-22
```

**3. Message Attributes (Optional):**
```json
{
  "eventType": {
    "DataType": "String",
    "StringValue": "announcement"
  },
  "priority": {
    "DataType": "String", 
    "StringValue": "normal"
  }
}
```

### Subscription Management:

#### **Email Subscription Process:**

**1. Subscription Creation:**
```json
{
  "Protocol": "email",
  "Endpoint": "user@example.com",
  "TopicArn": "arn:aws:sns:us-east-1:142595748980:event-announcements"
}
```

**2. Confirmation Flow:**
```
1. User subscribes to topic
2. SNS sends confirmation email
3. User clicks confirmation link
4. Subscription becomes active
5. User receives future messages
```

**3. Subscription States:**
- **PendingConfirmation**: Waiting for user confirmation
- **Confirmed**: Active subscription
- **Deleted**: Subscription removed

#### **SMS Subscription Process:**

**1. Subscription Creation:**
```json
{
  "Protocol": "sms",
  "Endpoint": "+1234567890",
  "TopicArn": "arn:aws:sns:us-east-1:142595748980:event-announcements"
}
```

**2. Automatic Confirmation:**
- SMS subscriptions are automatically confirmed
- No user action required
- Immediate message delivery

### SNS Delivery Reliability:

#### **Retry Logic:**
- **Automatic Retries**: Failed deliveries are retried
- **Exponential Backoff**: Increasing delays between retries
- **Dead Letter Queues**: Failed messages can be stored for analysis
- **Delivery Status**: Success/failure tracking available

#### **Delivery Policies:**
```json
{
  "default": {
    "healthyRetryPolicy": {
      "numRetries": 3,
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numMaxDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "throttlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
```

### SNS Security Features:

#### **Access Control:**
- **IAM Policies**: Control who can publish/subscribe
- **Topic Policies**: Resource-based permissions
- **Cross-Account Access**: Allow other AWS accounts
- **Encryption**: Messages encrypted in transit and at rest

#### **IAM Policy for Lambda:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sns:Publish"
      ],
      "Resource": "arn:aws:sns:us-east-1:142595748980:event-announcements"
    }
  ]
}
```

### SNS Monitoring and Metrics:

#### **CloudWatch Metrics:**
- **NumberOfMessagesPublished**: Messages sent to topic
- **NumberOfNotificationsDelivered**: Successful deliveries
- **NumberOfNotificationsFailed**: Failed deliveries
- **PublishSize**: Size of published messages

#### **Delivery Status Logging:**
- **Success Logs**: Successful message deliveries
- **Failure Logs**: Failed delivery attempts with reasons
- **CloudWatch Logs**: Centralized logging
- **Real-time Monitoring**: Immediate visibility into delivery status

### SNS Pricing:

#### **Request-Based Pricing:**
- **Email**: $2.00 per 100,000 notifications
- **SMS**: $0.75 per 100 notifications (US)
- **HTTP/HTTPS**: $0.60 per 1 million notifications
- **Mobile Push**: $0.50 per 1 million notifications

#### **Cost in Our Project:**
- **Email Notifications**: ~$0.02 per 1,000 emails
- **SMS Notifications**: ~$0.75 per 100 SMS
- **Low Volume**: Likely under $1/month
- **Free Tier**: 1,000 email notifications per month

### SNS Best Practices in Our Implementation:

#### **1. Message Formatting:**
- **Consistent Structure**: Professional message template
- **Visual Elements**: Emojis for better readability
- **Clear Information**: All essential event details included
- **Branding**: Consistent footer with system identification

#### **2. Error Handling:**
- **Graceful Degradation**: System continues if SNS fails
- **Logging**: All SNS operations logged for debugging
- **Retry Logic**: Built into SNS service
- **Monitoring**: CloudWatch metrics for delivery tracking

#### **3. Scalability:**
- **Fan-Out Pattern**: One message to many subscribers
- **Asynchronous**: Non-blocking message delivery
- **Regional**: Topic in same region as Lambda for lower latency
- **Unlimited Subscribers**: Can handle thousands of subscriptions

#### **4. Security:**
- **Least Privilege**: Lambda only has SNS publish permissions
- **Encryption**: Messages encrypted in transit
- **Access Control**: Topic access controlled via IAM
- **Audit Trail**: All actions logged in CloudTrail

### SNS Integration Benefits:

#### **Decoupling:**
- **Loose Coupling**: Lambda doesn't need to know about subscribers
- **Flexibility**: Easy to add/remove notification channels
- **Scalability**: Subscribers can be added without code changes
- **Reliability**: Message delivery handled by AWS

#### **Multi-Channel Support:**
- **Email**: Rich formatting, attachments possible
- **SMS**: Immediate delivery, high open rates
- **HTTP/HTTPS**: Integration with external systems
- **Lambda**: Trigger other functions
- **SQS**: Queue messages for processing

#### **Operational Benefits:**
- **Managed Service**: No infrastructure to maintain
- **High Availability**: Built-in redundancy
- **Global Reach**: SMS delivery worldwide
- **Cost Effective**: Pay only for messages sent

---
## 7. Monitoring and Observability

### What is Monitoring?

**Monitoring** is the practice of collecting, analyzing, and acting on data about your system's performance, health, and behavior. In cloud environments, monitoring provides visibility into distributed systems and helps ensure reliability, performance, and security.

### Types of Monitoring:

#### **1. Infrastructure Monitoring:**
- **Resource Utilization**: CPU, memory, network, storage
- **Service Health**: Availability and response times
- **Capacity Planning**: Usage trends and scaling needs

#### **2. Application Monitoring:**
- **Performance Metrics**: Response times, throughput
- **Error Tracking**: Exception rates and types
- **Business Metrics**: User actions and conversions

#### **3. Log Monitoring:**
- **Structured Logging**: Consistent log formats
- **Log Aggregation**: Centralized log collection
- **Log Analysis**: Pattern detection and alerting

### AWS CloudWatch Overview:

**Amazon CloudWatch** is AWS's native monitoring and observability service that provides data and actionable insights for AWS resources and applications.

#### **Core Components:**

**1. Metrics:**
- Numerical data points over time
- Automatically collected from AWS services
- Custom metrics from applications

**2. Logs:**
- Text-based log data from applications and services
- Centralized storage and analysis
- Real-time streaming and processing

**3. Alarms:**
- Automated responses to metric thresholds
- Notifications and automated actions
- Integration with SNS and Auto Scaling

**4. Dashboards:**
- Visual representation of metrics and logs
- Customizable charts and graphs
- Real-time and historical data views

### Monitoring in Our Project:

#### **System Architecture Monitoring:**
```
Frontend (S3) → API Gateway → Lambda → SNS → Email/SMS
     ↓              ↓           ↓       ↓
   Access Logs → Request Logs → Function Logs → Delivery Logs
```

### 1. Lambda Function Monitoring:

#### **Automatic Metrics:**
CloudWatch automatically collects these metrics for our Lambda function:

**Invocation Metrics:**
- **Invocations**: Number of times function is invoked
- **Duration**: Time function takes to execute
- **Errors**: Number of failed invocations
- **Throttles**: Number of throttled invocations
- **DeadLetterErrors**: Failed async invocations

**Performance Metrics:**
- **ConcurrentExecutions**: Number of concurrent executions
- **UnreservedConcurrentExecutions**: Available concurrency
- **ProvisionedConcurrencyInvocations**: Provisioned concurrency usage
- **ProvisionedConcurrencySpilloverInvocations**: Spillover invocations

#### **Custom Logging in Our Function:**
```python
# Structured logging for better monitoring
logger.info(f"Received event: {json.dumps(event)}")
logger.info(f"Parsed body: {json.dumps(body)}")
logger.info(f"Publishing message to SNS topic: {topic_arn}")
logger.info(f"Successfully published message with ID: {message_id}")
logger.error(f"Error processing event: {str(e)}")
```

**Log Group Location:**
- **Path**: `/aws/lambda/processEventAnnouncement`
- **Retention**: Configurable (default: never expire)
- **Format**: Structured JSON logs

#### **Sample Log Entries:**
```
[TIMESTAMP] [REQUEST ID] INFO Received event: {"httpMethod": "POST", "body": "..."}
[TIMESTAMP] [REQUEST ID] INFO Parsed body: {"title": "Team Meeting", "description": "..."}
[TIMESTAMP] [REQUEST ID] INFO Publishing message to SNS topic: arn:aws:sns:us-east-1:142595748980:event-announcements
[TIMESTAMP] [REQUEST ID] INFO Successfully published message with ID: 12345678-1234-1234-1234-123456789012
```

### 2. API Gateway Monitoring:

#### **Automatic Metrics:**
- **Count**: Number of API requests
- **Latency**: Time to process requests
- **IntegrationLatency**: Backend processing time
- **4XXError**: Client error rate
- **5XXError**: Server error rate

#### **Access Logging:**
API Gateway can log detailed request information:
```json
{
  "requestId": "739c616b-3e09-4528-b85d-9f5bf227dfda",
  "ip": "203.0.113.1",
  "caller": "142595748980",
  "user": "arn:aws:iam::142595748980:root",
  "requestTime": "15/Sep/2025:10:01:04 +0000",
  "httpMethod": "POST",
  "resourcePath": "/events",
  "status": "200",
  "protocol": "HTTP/1.1",
  "responseLength": "156"
}
```

#### **Execution Logs:**
Detailed request processing logs:
```
Starting execution for request: 739c616b-3e09-4528-b85d-9f5bf227dfda
HTTP Method: POST, Resource Path: /events
Method request body: {"title": "Test Event", "description": "..."}
Endpoint request URI: https://lambda.us-east-1.amazonaws.com/...
Received response. Status: 200, Integration latency: 90 ms
Method completed with status: 200
```

### 3. SNS Monitoring:

#### **Delivery Metrics:**
- **NumberOfMessagesPublished**: Messages sent to topic
- **NumberOfNotificationsDelivered**: Successful deliveries
- **NumberOfNotificationsFailed**: Failed deliveries
- **NumberOfNotificationsFilteredOut**: Filtered messages

#### **Protocol-Specific Metrics:**
**Email Metrics:**
- **NumberOfNotificationsDelivered-Email**: Successful email deliveries
- **NumberOfNotificationsFailed-Email**: Failed email deliveries

**SMS Metrics:**
- **NumberOfNotificationsDelivered-SMS**: Successful SMS deliveries
- **NumberOfNotificationsFailed-SMS**: Failed SMS deliveries

#### **Delivery Status Logging:**
```json
{
  "notification": {
    "messageId": "12345678-1234-1234-1234-123456789012",
    "topicArn": "arn:aws:sns:us-east-1:142595748980:event-announcements",
    "timestamp": "2024-12-15T10:01:05.000Z"
  },
  "delivery": {
    "deliveryId": "87654321-4321-4321-4321-210987654321",
    "destination": "user@example.com",
    "priceInUSD": 0.000002,
    "providerResponse": "Message delivered successfully",
    "dwellTimeMs": 1234
  },
  "status": "SUCCESS"
}
```

### 4. S3 Monitoring:

#### **Access Metrics:**
- **NumberOfObjects**: Objects in bucket
- **BucketSizeBytes**: Total bucket size
- **AllRequests**: Total requests to bucket
- **GetRequests**: GET requests (website visits)

#### **Access Logging:**
S3 can log all requests to the bucket:
```
79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be awsexamplebucket [06/Feb/2019:00:00:38 +0000] 192.0.2.3 79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be 3E57427F3EXAMPLE REST.GET.VERSIONING - "GET /awsexamplebucket?versioning HTTP/1.1" 200 - 113 - 7 - "-" "S3Console/0.4" - s9lzHYrFp76ZVxRcpX9+5cjAnEH2ROuNkd2BHfIa6UkFVdtjf5mKR3/eTPFvsiP/XV/VLi31234= SigV2 ECDHE-RSA-AES128-GCM-SHA256 AuthHeader awsexamplebucket.s3.amazonaws.com TLSV1.1
```

### Monitoring Dashboard Creation:

#### **CloudWatch Dashboard Components:**

**1. Lambda Function Dashboard:**
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/Lambda", "Invocations", "FunctionName", "processEventAnnouncement"],
          [".", "Duration", ".", "."],
          [".", "Errors", ".", "."]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "us-east-1",
        "title": "Lambda Function Metrics"
      }
    }
  ]
}
```

**2. API Gateway Dashboard:**
```json
{
  "type": "metric",
  "properties": {
    "metrics": [
      ["AWS/ApiGateway", "Count", "ApiName", "event-announcement-api"],
      [".", "Latency", ".", "."],
      [".", "4XXError", ".", "."],
      [".", "5XXError", ".", "."]
    ],
    "period": 300,
    "stat": "Average",
    "region": "us-east-1",
    "title": "API Gateway Metrics"
  }
}
```

### Alerting and Notifications:

#### **CloudWatch Alarms:**

**1. Lambda Error Rate Alarm:**
```json
{
  "AlarmName": "Lambda-ProcessEventAnnouncement-ErrorRate",
  "AlarmDescription": "Alert when Lambda error rate exceeds 5%",
  "MetricName": "Errors",
  "Namespace": "AWS/Lambda",
  "Statistic": "Sum",
  "Period": 300,
  "EvaluationPeriods": 2,
  "Threshold": 5,
  "ComparisonOperator": "GreaterThanThreshold",
  "AlarmActions": ["arn:aws:sns:us-east-1:142595748980:alerts"]
}
```

**2. API Gateway Latency Alarm:**
```json
{
  "AlarmName": "APIGateway-HighLatency",
  "AlarmDescription": "Alert when API latency exceeds 5 seconds",
  "MetricName": "Latency",
  "Namespace": "AWS/ApiGateway",
  "Statistic": "Average",
  "Period": 300,
  "EvaluationPeriods": 3,
  "Threshold": 5000,
  "ComparisonOperator": "GreaterThanThreshold"
}
```

### Log Analysis and Troubleshooting:

#### **Common Log Patterns:**

**1. Successful Request:**
```
START RequestId: 739c616b-3e09-4528-b85d-9f5bf227dfda Version: $LATEST
[INFO] Received event: {"httpMethod": "POST", "body": "..."}
[INFO] Parsed body: {"title": "Team Meeting", "description": "..."}
[INFO] Publishing message to SNS topic: arn:aws:sns:us-east-1:142595748980:event-announcements
[INFO] Successfully published message with ID: 12345678-1234-1234-1234-123456789012
END RequestId: 739c616b-3e09-4528-b85d-9f5bf227dfda
REPORT RequestId: 739c616b-3e09-4528-b85d-9f5bf227dfda Duration: 1234.56 ms Billed Duration: 1300 ms Memory Size: 128 MB Max Memory Used: 67 MB
```

**2. Error Pattern:**
```
START RequestId: 987f654e-4321-4321-4321-123456789abc Version: $LATEST
[INFO] Received event: {"httpMethod": "POST", "body": "..."}
[ERROR] JSON decode error: Expecting ',' delimiter: line 1 column 25 (char 24)
END RequestId: 987f654e-4321-4321-4321-123456789abc
REPORT RequestId: 987f654e-4321-4321-4321-123456789abc Duration: 45.67 ms Billed Duration: 100 ms Memory Size: 128 MB Max Memory Used: 45 MB
```

#### **Log Queries with CloudWatch Insights:**

**1. Find All Errors:**
```sql
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 20
```

**2. Analyze Response Times:**
```sql
fields @timestamp, @duration
| filter @type = "REPORT"
| stats avg(@duration), max(@duration), min(@duration) by bin(5m)
```

**3. Count Successful SNS Publications:**
```sql
fields @timestamp, @message
| filter @message like /Successfully published message/
| stats count() by bin(1h)
```

### Performance Optimization Through Monitoring:

#### **Key Performance Indicators (KPIs):**

**1. Response Time:**
- **Target**: < 200ms for API Gateway
- **Target**: < 1000ms for Lambda execution
- **Monitoring**: P50, P95, P99 percentiles

**2. Error Rate:**
- **Target**: < 1% error rate
- **Monitoring**: 4XX and 5XX errors
- **Alerting**: > 5% error rate

**3. Availability:**
- **Target**: 99.9% uptime
- **Monitoring**: Successful vs failed requests
- **SLA**: Based on AWS service SLAs

**4. Cost Efficiency:**
- **Lambda**: Optimize memory allocation based on usage
- **API Gateway**: Monitor request patterns
- **SNS**: Track delivery success rates

#### **Optimization Actions:**

**1. Lambda Optimization:**
- **Memory Tuning**: Adjust based on memory usage metrics
- **Cold Start Reduction**: Keep functions warm with scheduled invocations
- **Code Optimization**: Reduce execution time based on duration metrics

**2. API Gateway Optimization:**
- **Caching**: Enable response caching for GET requests
- **Compression**: Enable response compression
- **Regional Endpoints**: Use regional endpoints for lower latency

**3. SNS Optimization:**
- **Delivery Policies**: Tune retry policies based on failure rates
- **Message Filtering**: Reduce unnecessary deliveries
- **Batch Processing**: Group related notifications

### Monitoring Best Practices:

#### **1. Proactive Monitoring:**
- **Set up alerts before problems occur**
- **Monitor trends, not just current values**
- **Use composite alarms for complex conditions**

#### **2. Structured Logging:**
- **Consistent log format across all services**
- **Include correlation IDs for request tracing**
- **Log at appropriate levels (INFO, WARN, ERROR)**

#### **3. Dashboard Design:**
- **Focus on key metrics that matter**
- **Use appropriate time ranges and aggregations**
- **Include both technical and business metrics**

#### **4. Cost Management:**
- **Monitor CloudWatch costs**
- **Set log retention policies**
- **Use log sampling for high-volume applications**

### Monitoring ROI in Our Project:

#### **Benefits Achieved:**
- **Faster Issue Resolution**: Logs help identify problems quickly
- **Performance Optimization**: Metrics guide optimization efforts
- **Cost Control**: Usage monitoring prevents unexpected costs
- **Reliability**: Proactive alerting prevents outages
- **Compliance**: Audit trails for security and compliance

#### **Monitoring Costs:**
- **CloudWatch Logs**: $0.50 per GB ingested
- **CloudWatch Metrics**: $0.30 per metric per month
- **CloudWatch Alarms**: $0.10 per alarm per month
- **Dashboard**: $3.00 per dashboard per month

**Total Monthly Cost**: Typically $1-5 for our project scale

---

## Conclusion

This comprehensive overview covers all AWS services used in our Event Announcement System. Each service plays a crucial role in creating a scalable, reliable, and cost-effective serverless application:

- **Serverless Computing** provides automatic scaling and cost optimization
- **Event-Driven Architecture** enables loose coupling and flexibility
- **S3** offers reliable and cost-effective static website hosting
- **Lambda** handles business logic with automatic scaling
- **API Gateway** provides a secure and managed API layer
- **SNS** enables reliable multi-channel notifications
- **CloudWatch** provides comprehensive monitoring and observability

Together, these services create a production-ready system that demonstrates modern cloud architecture principles and AWS best practices.
