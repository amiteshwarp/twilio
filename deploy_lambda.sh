#!/bin/bash

# Lambda Email Webhook Deployment Script

set -e

# Configuration
FUNCTION_NAME="email-webhook-processor"
RUNTIME="python3.9"
HANDLER="lambda_email_webhook.lambda_handler"
ROLE_ARN="arn:aws:iam::YOUR_ACCOUNT_ID:role/lambda-execution-role"
WEBHOOK_URL="https://your-webhook-endpoint.com/email"
WEBHOOK_API_KEY="your-api-key-optional"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Lambda deployment...${NC}"

# Create deployment package
echo -e "${YELLOW}Creating deployment package...${NC}"
mkdir -p package
pip install -r requirements.txt -t package/
cp lambda_email_webhook.py package/
cd package
zip -r ../lambda_deployment.zip .
cd ..

# Check if function exists
if aws lambda get-function --function-name $FUNCTION_NAME >/dev/null 2>&1; then
    echo -e "${YELLOW}Updating existing function...${NC}"
    aws lambda update-function-code \
        --function-name $FUNCTION_NAME \
        --zip-file fileb://lambda_deployment.zip
    
    # Update environment variables
    aws lambda update-function-configuration \
        --function-name $FUNCTION_NAME \
        --environment Variables="{WEBHOOK_URL=$WEBHOOK_URL,WEBHOOK_API_KEY=$WEBHOOK_API_KEY}"
else
    echo -e "${YELLOW}Creating new function...${NC}"
    aws lambda create-function \
        --function-name $FUNCTION_NAME \
        --runtime $RUNTIME \
        --role $ROLE_ARN \
        --handler $HANDLER \
        --zip-file fileb://lambda_deployment.zip \
        --environment Variables="{WEBHOOK_URL=$WEBHOOK_URL,WEBHOOK_API_KEY=$WEBHOOK_API_KEY}" \
        --timeout 30 \
        --memory-size 256
fi

# Clean up
rm -rf package lambda_deployment.zip

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${YELLOW}Function ARN:${NC} arn:aws:lambda:$(aws configure get region):$(aws sts get-caller-identity --query Account --output text):function:$FUNCTION_NAME"

# Optional: Add SES trigger
echo -e "${YELLOW}To add SES trigger, run:${NC}"
echo "aws lambda add-permission --function-name $FUNCTION_NAME --statement-id ses-trigger --action lambda:InvokeFunction --principal ses.amazonaws.com"
echo "aws ses set-receipt-rule --rule-name your-rule-name --rule-set-name your-rule-set-name --actions Name=Lambda,InvocationType=Event,FunctionArn=arn:aws:lambda:$(aws configure get region):$(aws sts get-caller-identity --query Account --output text):function:$FUNCTION_NAME" 