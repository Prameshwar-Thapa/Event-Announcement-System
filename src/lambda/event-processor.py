import json
import boto3
import logging
from datetime import datetime
import os

# Initialize AWS services
sns = boto3.client('sns')
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    AWS Lambda function to process event announcements and send notifications via SNS
    
    Supports:
    - POST /events: Create and send event announcements
    - GET /events: Retrieve recent event announcements
    - OPTIONS: CORS preflight
    
    Expected POST input format:
    {
        "title": "Event Title",
        "description": "Event Description", 
        "date": "YYYY-MM-DD",
        "time": "HH:MM" (optional),
        "location": "Event Location" (optional)
    }
    """
    
    try:
        # Log the incoming event for debugging
        logger.info(f"Received event: {json.dumps(event)}")
        
        http_method = event.get('httpMethod', 'POST')
        
        # Handle OPTIONS request for CORS preflight
        if http_method == 'OPTIONS':
            return create_cors_response(200, '')
        
        # Handle GET request - retrieve recent announcements
        if http_method == 'GET':
            return handle_get_events(event)
        
        # Handle POST request - create and send announcement or manage subscriptions
        if http_method == 'POST':
            path = event.get('path', '')
            if '/subscribe' in path:
                return handle_subscribe(event)
            elif '/unsubscribe' in path:
                return handle_unsubscribe(event)
            else:
                return handle_post_event(event)
        
        # Unsupported method
        return create_cors_response(405, json.dumps({
            'success': False,
            'error': f'Method {http_method} not allowed'
        }))
        
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return create_error_response(500, "Internal server error occurred")

def handle_get_events(event):
    """Handle GET requests to retrieve recent announcements"""
    try:
        # In a real application, you would retrieve from a database
        # For this demo, we'll return a sample response
        recent_events = [
            {
                "id": "1",
                "title": "Welcome Party",
                "description": "Join us for a welcome party for new team members",
                "date": "2024-12-20",
                "time": "18:00",
                "location": "Conference Room A",
                "created_at": "2024-12-15T10:00:00Z"
            },
            {
                "id": "2", 
                "title": "Team Building Workshop",
                "description": "Interactive workshop to strengthen team collaboration",
                "date": "2024-12-22",
                "time": "14:00",
                "location": "Training Room B",
                "created_at": "2024-12-14T15:30:00Z"
            }
        ]
        
        return create_cors_response(200, json.dumps({
            'success': True,
            'events': recent_events,
            'count': len(recent_events),
            'timestamp': datetime.utcnow().isoformat() + 'Z'
        }))
        
    except Exception as e:
        logger.error(f"Error retrieving events: {str(e)}")
        return create_error_response(500, "Failed to retrieve events")

def handle_post_event(event):
    """Handle POST requests to create and send announcements"""
    try:
        # Parse the request body
        if 'body' not in event:
            raise ValueError("Request body is missing")
            
        body = json.loads(event['body'])
        logger.info(f"Parsed body: {json.dumps(body)}")
        
        # Validate required fields
        required_fields = ['title', 'description', 'date']
        for field in required_fields:
            if field not in body or not body[field].strip():
                raise ValueError(f"Missing or empty required field: {field}")
        
        # Extract event details
        event_title = body['title'].strip()
        event_description = body['description'].strip()
        event_date = body['date'].strip()
        event_time = body.get('time', '').strip()
        event_location = body.get('location', '').strip()
        
        # Validate date format (basic validation)
        try:
            datetime.strptime(event_date, '%Y-%m-%d')
        except ValueError:
            raise ValueError("Invalid date format. Use YYYY-MM-DD")
        
        # Create formatted message
        message_parts = [
            "🎉 NEW EVENT ANNOUNCEMENT 🎉",
            "",
            f"📅 Event: {event_title}",
            f"📝 Description: {event_description}",
            f"📆 Date: {event_date}"
        ]
        
        if event_time:
            message_parts.append(f"🕐 Time: {event_time}")
            
        if event_location:
            message_parts.append(f"📍 Location: {event_location}")
            
        message_parts.extend([
            "",
            "Don't miss out on this exciting event!",
            "",
            "---",
            "This is an automated notification from the Event Announcement System"
        ])
        
        message = "\n".join(message_parts)
        
        # Get SNS topic ARN from environment variable
        topic_arn = os.environ.get('SNS_TOPIC_ARN')
        if not topic_arn:
            # Fallback to hardcoded ARN (replace with your actual ARN)
            topic_arn = 'arn:aws:sns:us-east-1:123456789012:event-announcements'
            logger.warning("SNS_TOPIC_ARN environment variable not set, using fallback")
        
        # Create subject line
        subject = f"Event Announcement: {event_title}"
        if event_date:
            subject += f" - {event_date}"
        
        # Publish message to SNS topic
        logger.info(f"Publishing message to SNS topic: {topic_arn}")
        
        response = sns.publish(
            TopicArn=topic_arn,
            Message=message,
            Subject=subject
        )
        
        message_id = response['MessageId']
        logger.info(f"Successfully published message with ID: {message_id}")
        
        # Return success response
        return create_cors_response(200, json.dumps({
            'success': True,
            'message': 'Event announcement sent successfully!',
            'messageId': message_id,
            'eventTitle': event_title,
            'timestamp': datetime.utcnow().isoformat() + 'Z'
        }))
        
    except json.JSONDecodeError as e:
        logger.error(f"JSON decode error: {str(e)}")
        return create_error_response(400, "Invalid JSON format in request body")
        
    except ValueError as e:
        logger.error(f"Validation error: {str(e)}")
        return create_error_response(400, str(e))
        
    except Exception as e:
        logger.error(f"Unexpected error processing event: {str(e)}")
        return create_error_response(500, "Internal server error occurred while processing the event announcement")

def handle_subscribe(event):
    """Handle subscription requests"""
    try:
        body = json.loads(event['body'])
        
        # Validate required fields
        if 'protocol' not in body or 'endpoint' not in body:
            raise ValueError("Missing required fields: protocol and endpoint")
        
        protocol = body['protocol'].lower()
        endpoint = body['endpoint'].strip()
        
        # Validate protocol
        if protocol not in ['email', 'sms']:
            raise ValueError("Protocol must be 'email' or 'sms'")
        
        # Get SNS topic ARN
        topic_arn = os.environ.get('SNS_TOPIC_ARN')
        if not topic_arn:
            topic_arn = 'arn:aws:sns:us-east-1:123456789012:event-announcements'
        
        # Subscribe to topic
        response = sns.subscribe(
            TopicArn=topic_arn,
            Protocol=protocol,
            Endpoint=endpoint
        )
        
        subscription_arn = response['SubscriptionArn']
        logger.info(f"Created subscription: {subscription_arn}")
        
        return create_cors_response(200, json.dumps({
            'success': True,
            'message': f'Successfully subscribed {endpoint} to notifications',
            'subscriptionArn': subscription_arn,
            'protocol': protocol,
            'endpoint': endpoint
        }))
        
    except Exception as e:
        logger.error(f"Subscription error: {str(e)}")
        return create_error_response(400, str(e))

def handle_unsubscribe(event):
    """Handle unsubscription requests"""
    try:
        body = json.loads(event['body'])
        
        if 'subscriptionArn' not in body:
            raise ValueError("Missing required field: subscriptionArn")
        
        subscription_arn = body['subscriptionArn']
        
        # Unsubscribe from topic
        sns.unsubscribe(SubscriptionArn=subscription_arn)
        
        logger.info(f"Unsubscribed: {subscription_arn}")
        
        return create_cors_response(200, json.dumps({
            'success': True,
            'message': 'Successfully unsubscribed from notifications'
        }))
        
    except Exception as e:
        logger.error(f"Unsubscription error: {str(e)}")
        return create_error_response(400, str(e))

def create_cors_response(status_code, body):
    """Create response with CORS headers"""
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

def create_error_response(status_code, error_message):
    """
    Create a standardized error response
    """
    return create_cors_response(status_code, json.dumps({
        'success': False,
        'error': error_message,
        'timestamp': datetime.utcnow().isoformat() + 'Z'
    }))

# Test function for local development
if __name__ == "__main__":
    # Sample test event
    test_event = {
        'httpMethod': 'POST',
        'body': json.dumps({
            'title': 'Team Building Event',
            'description': 'Join us for a fun team building activity with games and refreshments',
            'date': '2024-12-20',
            'time': '14:00',
            'location': 'Conference Room A'
        })
    }
    
    # Test the function
    result = lambda_handler(test_event, None)
    print(json.dumps(result, indent=2))
