import json
import base64
import email
import requests
import os
import asyncio
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
from datetime import datetime
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    AWS Lambda function to process email MIME content and forward to webhook API
    
    Expected event structure:
    {
        "Records": [
            {
                "ses": {
                    "mail": {
                        "messageId": "string",
                        "timestamp": "string",
                        "source": "sender@example.com",
                        "destination": ["recipient@example.com"],
                        "headersTruncated": false,
                        "headers": [...],
                        "commonHeaders": {...},
                        "content": "base64_encoded_mime_content"
                    }
                }
            }
        ]
    }
    """
    
    try:
        # Get webhook URL from environment variable
        webhook_url = os.environ.get('WEBHOOK_URL')
        if not webhook_url:
            raise ValueError("WEBHOOK_URL environment variable is not set")
        
        # Process each record in the event
        for record in event.get('Records', []):
            if 'ses' in record and 'mail' in record['ses']:
                mail_data = record['ses']['mail']
                process_email_record(mail_data, webhook_url, context)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Email processed successfully',
                'processed_records': len(event.get('Records', []))
            })
        }
        
    except Exception as e:
        logger.error(f"Error processing email: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Failed to process email',
                'message': str(e)
            })
        }

def process_email_record(mail_data, webhook_url, context):
    """
    Process a single email record and forward to webhook
    """
    try:
        # Extract basic email information
        message_id = mail_data.get('messageId', '')
        timestamp = mail_data.get('timestamp', '')
        source = mail_data.get('source', '')
        destination = mail_data.get('destination', [])
        headers = mail_data.get('headers', [])
        common_headers = mail_data.get('commonHeaders', {})
        
        # Get MIME content
        mime_content = mail_data.get('content', '')
        if not mime_content:
            logger.warning(f"No MIME content found for message {message_id}")
            return
        
        # Decode base64 MIME content
        try:
            decoded_content = base64.b64decode(mime_content)
            email_message = email.message_from_bytes(decoded_content)
        except Exception as e:
            logger.error(f"Failed to decode MIME content for message {message_id}: {str(e)}")
            return
        
        # Parse email content
        parsed_email = parse_email_content(email_message)
        
        # Prepare JSON payload
        json_payload = {
            'message_id': message_id,
            'timestamp': timestamp,
            'source': source,
            'destination': destination,
            'headers': headers,
            'common_headers': common_headers,
            'parsed_content': parsed_email,
            'processed_at': datetime.utcnow().isoformat() + 'Z'
        }
        
        # Prepare webhook request with both MIME and JSON
        webhook_data = {
            'mime_content': mime_content,  # Original base64 encoded MIME
            'json_content': json_payload,  # Parsed JSON content
            'metadata': {
                'source': 'aws_lambda',
                'function_name': context.function_name,
                'request_id': context.aws_request_id
            }
        }
        
        # Send to webhook
        send_to_webhook(webhook_url, webhook_data)
        
        logger.info(f"Successfully processed and forwarded email {message_id}")
        
    except Exception as e:
        logger.error(f"Error processing email record: {str(e)}")
        raise

def parse_email_content(email_message):
    """
    Parse email MIME content and extract relevant information
    """
    parsed = {
        'subject': email_message.get('Subject', ''),
        'from': email_message.get('From', ''),
        'to': email_message.get('To', ''),
        'cc': email_message.get('Cc', ''),
        'bcc': email_message.get('Bcc', ''),
        'date': email_message.get('Date', ''),
        'message_id': email_message.get('Message-ID', ''),
        'content_type': email_message.get_content_type(),
        'body': {
            'text': '',
            'html': ''
        },
        'attachments': []
    }
    
    # Extract body content
    if email_message.is_multipart():
        for part in email_message.walk():
            content_type = part.get_content_type()
            content_disposition = str(part.get('Content-Disposition', ''))
            
            # Handle attachments
            if 'attachment' in content_disposition:
                attachment_info = {
                    'filename': part.get_filename(),
                    'content_type': content_type,
                    'size': len(part.get_payload(decode=True)) if part.get_payload(decode=True) else 0
                }
                parsed['attachments'].append(attachment_info)
            
            # Handle body content
            elif content_type == 'text/plain':
                try:
                    parsed['body']['text'] = part.get_payload(decode=True).decode('utf-8', errors='ignore')
                except:
                    parsed['body']['text'] = part.get_payload(decode=True).decode('latin-1', errors='ignore')
            
            elif content_type == 'text/html':
                try:
                    parsed['body']['html'] = part.get_payload(decode=True).decode('utf-8', errors='ignore')
                except:
                    parsed['body']['html'] = part.get_payload(decode=True).decode('latin-1', errors='ignore')
    else:
        # Non-multipart message
        content_type = email_message.get_content_type()
        if content_type == 'text/plain':
            try:
                parsed['body']['text'] = email_message.get_payload(decode=True).decode('utf-8', errors='ignore')
            except:
                parsed['body']['text'] = email_message.get_payload(decode=True).decode('latin-1', errors='ignore')
        elif content_type == 'text/html':
            try:
                parsed['body']['html'] = email_message.get_payload(decode=True).decode('utf-8', errors='ignore')
            except:
                parsed['body']['html'] = email_message.get_payload(decode=True).decode('latin-1', errors='ignore')
    
    return parsed

def send_to_webhook(webhook_url, data):
    """
    Send data to webhook API
    """
    try:
        headers = {
            'Content-Type': 'application/json',
            'User-Agent': 'AWS-Lambda-Email-Webhook/1.0'
        }
        
        # Add optional authentication headers
        api_key = os.environ.get('WEBHOOK_API_KEY')
        if api_key:
            headers['Authorization'] = f'Bearer {api_key}'
        
        response = requests.post(
            webhook_url,
            json=data,
            headers=headers,
            timeout=30
        )
        
        if response.status_code >= 200 and response.status_code < 300:
            logger.info(f"Successfully sent to webhook: {response.status_code}")
        else:
            logger.error(f"Webhook request failed: {response.status_code} - {response.text}")
            
    except requests.exceptions.RequestException as e:
        logger.error(f"Failed to send to webhook: {str(e)}")
        raise

# For testing purposes (when not running in Lambda)
def test_handler():
    """
    Test function for local development
    """
    # Sample test event
    test_event = {
        "Records": [
            {
                "ses": {
                    "mail": {
                        "messageId": "test-message-id",
                        "timestamp": "2024-01-01T00:00:00Z",
                        "source": "test@example.com",
                        "destination": ["recipient@example.com"],
                        "headersTruncated": False,
                        "headers": [
                            {"name": "From", "value": "test@example.com"},
                            {"name": "To", "value": "recipient@example.com"},
                            {"name": "Subject", "value": "Test Email"}
                        ],
                        "commonHeaders": {
                            "from": ["test@example.com"],
                            "to": ["recipient@example.com"],
                            "subject": "Test Email"
                        },
                        "content": base64.b64encode(b"""From: test@example.com
To: recipient@example.com
Subject: Test Email
Content-Type: text/plain

This is a test email body.""".encode()).decode()
                    }
                }
            }
        ]
    }
    
    # Mock context
    class MockContext:
        function_name = "test-function"
        aws_request_id = "test-request-id"
    
    context = MockContext()
    
    # Set test environment variable
    os.environ['WEBHOOK_URL'] = 'https://httpbin.org/post'
    
    # Run test
    result = lambda_handler(test_event, context)
    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    test_handler() 