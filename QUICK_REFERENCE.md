# Quick Reference Guide

## 🚀 Deployment Commands

### Infrastructure
```bash
# Deploy CloudFormation stack
aws cloudformation create-stack \
  --stack-name contract-ai-stack \
  --template-body file://infrastructure/cloudformation/main.yaml \
  --capabilities CAPABILITY_NAMED_IAM

# Check stack status
aws cloudformation describe-stacks --stack-name contract-ai-stack
```

### Lambda Functions
```bash
# Deploy all functions
cd backend && ./scripts/deploy.sh

# Deploy single function
cd backend/lambdas/uploadHandler
zip -r function.zip .
aws lambda update-function-code \
  --function-name contract-ai-upload-handler-dev \
  --zip-file fileb://function.zip
```

### Frontend
```bash
# Build and deploy
cd frontend
npm install
npm run build
aws s3 sync out/ s3://YOUR-BUCKET-NAME --delete
```

## 📋 Environment Variables

### Lambda Functions
```bash
UPLOAD_BUCKET_NAME=contract-ai-uploads-dev
TEXTRACT_BUCKET_NAME=contract-ai-textract-dev
CONTRACTS_TABLE=contract-ai-contracts-dev
CLAUSES_TABLE=contract-ai-clauses-dev
SQS_QUEUE_URL=https://sqs.us-east-1.amazonaws.com/ACCOUNT/queue
SNS_TOPIC_ARN=arn:aws:sns:us-east-1:ACCOUNT:topic
SAGEMAKER_ENDPOINT_NAME=contract-risk-scorer
BEDROCK_MODEL_ID=anthropic.claude-3-sonnet-20240229-v1:0
```

### Frontend
```bash
NEXT_PUBLIC_API_URL=https://api.contract-ai.example.com
```

## 🔍 Useful AWS CLI Commands

### S3
```bash
# List buckets
aws s3 ls

# Upload file
aws s3 cp contract.pdf s3://contract-ai-uploads-dev/contracts/

# List objects
aws s3 ls s3://contract-ai-uploads-dev/contracts/
```

### Lambda
```bash
# List functions
aws lambda list-functions --query "Functions[?contains(FunctionName, 'contract-ai')]"

# Invoke function
aws lambda invoke --function-name contract-ai-upload-handler-dev output.json

# View logs
aws logs tail /aws/lambda/contract-ai-upload-handler-dev --follow
```

### DynamoDB
```bash
# List tables
aws dynamodb list-tables

# Get item
aws dynamodb get-item \
  --table-name contract-ai-contracts-dev \
  --key '{"contract_id": {"S": "uuid"}}'

# Scan table
aws dynamodb scan --table-name contract-ai-contracts-dev --limit 10
```

### API Gateway
```bash
# List APIs
aws apigateway get-rest-apis

# Get API details
aws apigateway get-rest-api --rest-api-id API_ID
```

## 🐛 Troubleshooting

### Lambda Timeout
```bash
aws lambda update-function-configuration \
  --function-name contract-ai-bedrock-analyzer-dev \
  --timeout 300
```

### Check IAM Permissions
```bash
aws iam get-role --role-name contract-ai-lambda-role-dev
aws iam list-attached-role-policies --role-name contract-ai-lambda-role-dev
```

### View CloudWatch Logs
```bash
aws logs tail /aws/lambda/contract-ai-upload-handler-dev --follow
aws logs filter-log-events \
  --log-group-name /aws/lambda/contract-ai-upload-handler-dev \
  --filter-pattern "ERROR"
```

### Test Bedrock Access
```bash
aws bedrock list-foundation-models \
  --query "modelSummaries[?contains(modelId, 'claude')]"
```

### Check SageMaker Endpoint
```bash
aws sagemaker describe-endpoint --endpoint-name contract-risk-scorer
```

## 📊 Monitoring

### CloudWatch Metrics
```bash
# Get Lambda metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --dimensions Name=FunctionName,Value=contract-ai-upload-handler-dev \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Sum
```

### Create Alarm
```bash
aws cloudwatch put-metric-alarm \
  --alarm-name contract-ai-lambda-errors \
  --alarm-description "Alert on Lambda errors" \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 5
```

## 🔐 Security

### Update IAM Role
```bash
aws iam update-assume-role-policy \
  --role-name contract-ai-lambda-role-dev \
  --policy-document file://trust-policy.json
```

### Encrypt S3 Bucket
```bash
aws s3api put-bucket-encryption \
  --bucket contract-ai-uploads-dev \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

## 🧪 Testing

### Test API Endpoint
```bash
curl -X POST https://API-GATEWAY-URL/upload \
  -H "Content-Type: application/json" \
  -d '{"filename": "test.pdf", "file_content": "base64..."}'
```

### Test Lambda Locally (SAM)
```bash
sam local invoke UploadHandlerFunction -e events/upload-event.json
```

## 📝 Common Tasks

### Update Lambda Environment Variables
```bash
aws lambda update-function-configuration \
  --function-name contract-ai-upload-handler-dev \
  --environment Variables="{UPLOAD_BUCKET_NAME=contract-ai-uploads-dev}"
```

### Enable S3 EventBridge
```bash
aws s3api put-bucket-notification-configuration \
  --bucket contract-ai-uploads-dev \
  --notification-configuration '{
    "EventBridgeConfiguration": {}
  }'
```

### Subscribe to SNS
```bash
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:ACCOUNT:contract-ai-notifications-dev \
  --protocol email \
  --notification-endpoint your-email@example.com
```

## 🎯 Key URLs

- **CloudFormation Console**: https://console.aws.amazon.com/cloudformation
- **Lambda Console**: https://console.aws.amazon.com/lambda
- **S3 Console**: https://console.aws.amazon.com/s3
- **DynamoDB Console**: https://console.aws.amazon.com/dynamodb
- **API Gateway Console**: https://console.aws.amazon.com/apigateway
- **Bedrock Console**: https://console.aws.amazon.com/bedrock
- **SageMaker Console**: https://console.aws.amazon.com/sagemaker

## 💡 Pro Tips

1. **Use AWS SAM** for local Lambda testing
2. **Enable X-Ray** for distributed tracing
3. **Set up CloudWatch Dashboards** for monitoring
4. **Use RDS Proxy** for connection pooling
5. **Enable S3 versioning** for production
6. **Configure WAF** for API Gateway
7. **Use Secrets Manager** for credentials
8. **Set up CloudFront** for global CDN
9. **Enable AWS Shield** for DDoS protection
10. **Use AWS Config** for compliance

