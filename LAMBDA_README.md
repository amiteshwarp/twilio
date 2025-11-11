# AWS Lambda Email Webhook Processor

This Lambda function processes incoming emails from Amazon SES and forwards them to a webhook API with both MIME and JSON content formats.

## Features

- **MIME Processing**: Receives and decodes base64-encoded MIME email content
- **JSON Parsing**: Extracts email metadata and content into structured JSON
- **Webhook Forwarding**: Sends both MIME and JSON data to external webhook endpoints
- **Attachment Handling**: Processes email attachments and includes metadata
- **Error Handling**: Comprehensive error handling and logging
- **Authentication**: Optional API key authentication for webhook endpoints

## Architecture

```
Email → Amazon SES → Lambda Function → External Webhook API
```

## Prerequisites

- AWS CLI configured with appropriate permissions
- Python 3.9+ (for local testing)
- An external webhook endpoint to receive the processed emails

## Installation

### Option 1: Using CloudFormation (Recommended)

1. **Update the template parameters**:
   ```bash
   # Edit cloudformation-template.yaml
   # Update WebhookUrl and WebhookApiKey parameters
   ```

2. **Deploy the stack**:
   ```bash
   aws cloudformation create-stack \
     --stack-name email-webhook-processor \
     --template-body file://cloudformation-template.yaml \
     --parameters ParameterKey=WebhookUrl,ParameterValue=https://your-webhook.com/email \
                  ParameterKey=WebhookApiKey,ParameterValue=your-api-key \
     --capabilities CAPABILITY_NAMED_IAM
   ```

### Option 2: Using Deployment Script

1. **Update configuration** in `deploy_lambda.sh`:
   ```bash
   FUNCTION_NAME="email-webhook-processor"
   ROLE_ARN="arn:aws:iam::YOUR_ACCOUNT_ID:role/lambda-execution-role"
   WEBHOOK_URL="https://your-webhook-endpoint.com/email"
   WEBHOOK_API_KEY="your-api-key-optional"
   ```

2. **Make script executable and run**:
   ```bash
   chmod +x deploy_lambda.sh
   ./deploy_lambda.sh
   ```

### Option 3: Manual Deployment

1. **Create deployment package**:
   ```bash
   mkdir package
   pip install -r requirements.txt -t package/
   cp lambda_email_webhook.py package/
   cd package
   zip -r ../lambda_deployment.zip .
   cd ..
   ```

2. **Create Lambda function**:
   ```bash
   aws lambda create-function \
     --function-name email-webhook-processor \
     --runtime python3.9 \
     --role arn:aws:iam::YOUR_ACCOUNT_ID:role/lambda-execution-role \
     --handler lambda_email_webhook.lambda_handler \
     --zip-file fileb://lambda_deployment.zip \
     --environment Variables="{WEBHOOK_URL=https://your-webhook.com/email,WEBHOOK_API_KEY=your-api-key}" \
     --timeout 30 \
     --memory-size 256
   ```

## Configuration

### Environment Variables

- `WEBHOOK_URL` (required): The URL of your webhook endpoint
- `WEBHOOK_API_KEY` (optional): API key for webhook authentication

### SES Configuration

1. **Verify your domain** in Amazon SES
2. **Create a receipt rule** to trigger the Lambda function:
   ```bash
   aws ses create-receipt-rule \
     --rule-set-name your-rule-set \
     --rule '{
       "Name": "email-webhook-rule",
       "Enabled": true,
       "Recipients": ["your-domain.com"],
       "Actions": [
         {
           "LambdaAction": {
             "FunctionArn": "arn:aws:lambda:region:account:function:email-webhook-processor",
             "InvocationType": "Event"
           }
         }
       ]
     }'
   ```

## Webhook Payload Format

The Lambda function sends the following JSON structure to your webhook:

```json
{
  "mime_content": "base64_encoded_original_mime",
  "json_content": {
    "message_id": "unique-message-id",
    "timestamp": "2024-01-01T00:00:00Z",
    "source": "sender@example.com",
    "destination": ["recipient@example.com"],
    "headers": [...],
    "common_headers": {...},
    "parsed_content": {
      "subject": "Email Subject",
      "from": "sender@example.com",
      "to": "recipient@example.com",
      "cc": "cc@example.com",
      "bcc": "bcc@example.com",
      "date": "Mon, 1 Jan 2024 00:00:00 +0000",
      "message_id": "<message-id@example.com>",
      "content_type": "multipart/mixed",
      "body": {
        "text": "Plain text content",
        "html": "<html>HTML content</html>"
      },
      "attachments": [
        {
          "filename": "document.pdf",
          "content_type": "application/pdf",
          "size": 1024
        }
      ]
    },
    "processed_at": "2024-01-01T00:00:00Z"
  },
  "metadata": {
    "source": "aws_lambda",
    "function_name": "email-webhook-processor",
    "request_id": "lambda-request-id"
  }
}
```

## Testing

### Local Testing

Run the test function locally:

```bash
python lambda_email_webhook.py
```

### AWS Testing

1. **Test with sample event**:
   ```bash
   aws lambda invoke \
     --function-name email-webhook-processor \
     --payload file://test-event.json \
     response.json
   ```

2. **Check logs**:
   ```bash
   aws logs tail /aws/lambda/email-webhook-processor --follow
   ```

## Monitoring

### CloudWatch Metrics

Monitor the following metrics:
- Invocation count
- Error rate
- Duration
- Throttles

### CloudWatch Logs

Log groups: `/aws/lambda/email-webhook-processor`

Key log entries:
- Email processing success/failure
- Webhook delivery status
- Error details

## Troubleshooting

### Common Issues

1. **Permission Denied**:
   - Ensure Lambda has permission to invoke your webhook
   - Check IAM role permissions

2. **Webhook Timeout**:
   - Increase Lambda timeout (max 15 minutes)
   - Check webhook endpoint response time

3. **MIME Decoding Errors**:
   - Verify SES is sending proper base64 content
   - Check email encoding

4. **Memory Issues**:
   - Increase Lambda memory allocation
   - Large attachments may require more memory

### Debug Mode

Enable detailed logging by setting the log level:

```python
logger.setLevel(logging.DEBUG)
```

## Security Considerations

1. **Webhook Authentication**: Use the `WEBHOOK_API_KEY` for authentication
2. **HTTPS Only**: Ensure webhook endpoints use HTTPS
3. **Input Validation**: Validate webhook payloads on your endpoint
4. **Rate Limiting**: Implement rate limiting on your webhook endpoint

## Cost Optimization

- **Reserved Concurrency**: Set appropriate concurrency limits
- **Memory Optimization**: Use minimum required memory
- **Log Retention**: Set appropriate CloudWatch log retention periods

## Support

For issues and questions:
1. Check CloudWatch logs for error details
2. Verify webhook endpoint is accessible
3. Test with sample events
4. Review SES configuration

## License

This project is open-source and available under the MIT License. 