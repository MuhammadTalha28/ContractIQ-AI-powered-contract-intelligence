# Deployment Guide

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
3. **Node.js 18+** and npm
4. **Python 3.9+** and pip
5. **Terraform** (optional, for IaC)
6. **Docker** (for SageMaker model training)

## Step-by-Step Deployment

### Phase 1: Infrastructure Setup

1. **Deploy CloudFormation Stack**:
```bash
cd infrastructure/cloudformation
aws cloudformation create-stack \
  --stack-name contract-ai-stack \
  --template-body file://main.yaml \
  --parameters ParameterKey=Environment,ParameterValue=dev \
  --capabilities CAPABILITY_NAMED_IAM
```

2. **Wait for Stack Creation** (5-10 minutes):
```bash
aws cloudformation wait stack-create-complete --stack-name contract-ai-stack
```

3. **Get Stack Outputs**:
```bash
aws cloudformation describe-stacks --stack-name contract-ai-stack
```

### Phase 2: RDS Database Setup

1. **Create RDS Instance** (via Console or CLI):
```bash
aws rds create-db-instance \
  --db-instance-identifier contract-ai-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password YourSecurePassword \
  --allocated-storage 20
```

2. **Run Schema**:
```bash
psql -h <rds-endpoint> -U admin -d postgres -f backend/database/rds_schema.sql
```

### Phase 3: Deploy Lambda Functions

1. **Deploy All Functions**:
```bash
cd backend
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

Or deploy individually:
```bash
cd backend/lambdas/uploadHandler
zip -r function.zip .
aws lambda update-function-code \
  --function-name contract-ai-upload-handler-dev \
  --zip-file fileb://function.zip
```

### Phase 4: Deploy SageMaker Model

1. **Train Model Locally** (optional):
```bash
cd backend/models
python risk_scorer_model.py
```

2. **Deploy to SageMaker**:
```bash
python train_sagemaker.py
```

### Phase 5: Configure API Gateway

1. **Create API Gateway** (if not via CloudFormation):
```bash
aws apigateway create-rest-api --name contract-ai-api
```

2. **Create Resources and Methods**:
- POST /upload → uploadHandler Lambda
- GET /contracts → DynamoDB query
- GET /contracts/{id} → Get contract details

3. **Enable CORS**:
```bash
aws apigateway put-method-response \
  --rest-api-id <api-id> \
  --resource-id <resource-id> \
  --http-method OPTIONS \
  --status-code 200
```

### Phase 6: Deploy Frontend

1. **Build Next.js App**:
```bash
cd frontend
npm install
npm run build
```

2. **Deploy to S3 + CloudFront**:
```bash
# Upload to S3
aws s3 sync out/ s3://contract-ai-frontend-bucket --delete

# Create CloudFront distribution
aws cloudfront create-distribution \
  --origin-domain-name contract-ai-frontend-bucket.s3.amazonaws.com
```

### Phase 7: Configure Environment Variables

Set environment variables in Lambda functions:
```bash
aws lambda update-function-configuration \
  --function-name contract-ai-upload-handler-dev \
  --environment Variables="{
    UPLOAD_BUCKET_NAME=contract-ai-uploads-dev,
    CONTRACTS_TABLE=contract-ai-contracts-dev
  }"
```

### Phase 8: Set Up Monitoring

1. **Create CloudWatch Alarms**:
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

2. **Set Up SNS Email Subscription**:
```bash
aws sns subscribe \
  --topic-arn <topic-arn> \
  --protocol email \
  --notification-endpoint your-email@example.com
```

## CI/CD Setup

### GitHub Actions

1. **Add Secrets to GitHub**:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `API_GATEWAY_URL`
   - `S3_BUCKET_NAME`
   - `CLOUDFRONT_DISTRIBUTION_ID`

2. **Push to Main Branch**:
   - Automatic deployment via GitHub Actions
   - See `.github/workflows/deploy.yml`

### AWS CodePipeline (Alternative)

1. **Create Pipeline**:
```bash
aws codepipeline create-pipeline --cli-input-json file://pipeline.json
```

## Verification

1. **Test Upload Endpoint**:
```bash
curl -X POST https://<api-gateway-url>/upload \
  -H "Content-Type: application/json" \
  -d '{"filename": "test.pdf", "file_content": "base64..."}'
```

2. **Check Lambda Logs**:
```bash
aws logs tail /aws/lambda/contract-ai-upload-handler-dev --follow
```

3. **Verify S3 Upload**:
```bash
aws s3 ls s3://contract-ai-uploads-dev/contracts/
```

## Troubleshooting

### Common Issues

1. **Lambda Timeout**: Increase timeout in function configuration
2. **Permission Errors**: Check IAM roles and policies
3. **Bedrock Access**: Request model access in AWS Console
4. **SageMaker Endpoint**: Ensure endpoint is in "InService" state
5. **CORS Errors**: Configure API Gateway CORS properly

## Cost Estimation

Estimated monthly costs (dev environment):
- Lambda: ~$5-10 (pay per use)
- S3: ~$1-5 (storage + requests)
- DynamoDB: ~$1-3 (on-demand)
- API Gateway: ~$3-5 (first 1M requests free)
- Textract: ~$1.50 per 1000 pages
- Bedrock: ~$0.003 per 1K input tokens
- SageMaker: ~$50-100 (endpoint running 24/7)
- CloudFront: ~$1-5 (data transfer)

**Total**: ~$65-130/month for dev environment

## Production Checklist

- [ ] Enable CloudWatch detailed monitoring
- [ ] Set up VPC for RDS
- [ ] Configure RDS backups
- [ ] Enable S3 versioning and lifecycle policies
- [ ] Set up CloudFront with custom domain
- [ ] Configure WAF for API Gateway
- [ ] Enable AWS Shield (DDoS protection)
- [ ] Set up AWS Secrets Manager for credentials
- [ ] Configure auto-scaling for SageMaker
- [ ] Set up CloudWatch dashboards
- [ ] Configure alerting via SNS
- [ ] Enable AWS X-Ray tracing
- [ ] Set up disaster recovery plan

