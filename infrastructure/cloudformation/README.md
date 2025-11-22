# CloudFormation Infrastructure

This directory contains CloudFormation templates for deploying the complete AWS infrastructure.

## Deployment

### Prerequisites
- AWS CLI configured with appropriate credentials
- AWS account with permissions to create resources

### Deploy Stack

```bash
aws cloudformation create-stack \
  --stack-name contract-ai-stack \
  --template-body file://main.yaml \
  --parameters ParameterKey=Environment,ParameterValue=dev \
  --capabilities CAPABILITY_NAMED_IAM
```

### Update Stack

```bash
aws cloudformation update-stack \
  --stack-name contract-ai-stack \
  --template-body file://main.yaml \
  --parameters ParameterKey=Environment,ParameterValue=dev \
  --capabilities CAPABILITY_NAMED_IAM
```

### Delete Stack

```bash
aws cloudformation delete-stack --stack-name contract-ai-stack
```

## Resources Created

- **S3 Buckets**: Upload and Textract results storage
- **DynamoDB Tables**: Contracts and clauses metadata
- **SQS Queue**: Async processing queue
- **SNS Topic**: Notifications
- **Lambda Functions**: All processing functions
- **API Gateway**: REST API endpoints
- **EventBridge Rule**: S3 upload triggers
- **IAM Roles**: Permissions for Lambda functions
- **CloudWatch Log Groups**: Logging

## Notes

- Replace `ACCOUNT` in IAM role ARNs with your AWS account ID
- Configure Bedrock model access in your AWS account
- Set up RDS separately (not included in this template)
- Configure CloudFront distribution separately for frontend

