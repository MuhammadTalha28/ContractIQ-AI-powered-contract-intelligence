# Setup Guide

## Local Development Setup

### Frontend Setup

1. **Install Dependencies**:
```bash
cd frontend
npm install
```

2. **Set Environment Variables**:
Create `frontend/.env.local`:
```
NEXT_PUBLIC_API_URL=http://localhost:3001
```

3. **Run Development Server**:
```bash
npm run dev
```

Frontend will be available at `http://localhost:3000`

### Backend Setup

1. **Install Python Dependencies**:
```bash
cd backend
pip install -r lambdas/uploadHandler/requirements.txt
pip install -r lambdas/textractProcessor/requirements.txt
pip install -r lambdas/bedrockAnalyzer/requirements.txt
pip install -r lambdas/sageMakerScorer/requirements.txt
pip install -r lambdas/notifyUser/requirements.txt
```

2. **Configure AWS Credentials**:
```bash
aws configure
```

3. **Set Environment Variables**:
Create `.env` file:
```
AWS_REGION=us-east-1
UPLOAD_BUCKET_NAME=contract-ai-uploads-dev
TEXTRACT_BUCKET_NAME=contract-ai-textract-dev
CONTRACTS_TABLE=contract-ai-contracts-dev
CLAUSES_TABLE=contract-ai-clauses-dev
SQS_QUEUE_URL=https://sqs.us-east-1.amazonaws.com/ACCOUNT/contract-ai-processing-dev
SNS_TOPIC_ARN=arn:aws:sns:us-east-1:ACCOUNT:contract-ai-notifications-dev
SAGEMAKER_ENDPOINT_NAME=contract-risk-scorer
BEDROCK_MODEL_ID=anthropic.claude-3-sonnet-20240229-v1:0
```

### Local Testing

1. **Test Lambda Functions Locally**:
```bash
# Install SAM CLI
pip install aws-sam-cli

# Test upload handler
sam local invoke UploadHandlerFunction -e events/upload-event.json
```

2. **Run Unit Tests**:
```bash
cd backend
pytest tests/
```

## AWS Account Setup

### Required Permissions

Your AWS user/role needs:
- Lambda: Create, update, invoke functions
- S3: Create buckets, upload/download objects
- DynamoDB: Create tables, read/write items
- API Gateway: Create APIs, resources, methods
- IAM: Create roles and policies
- CloudFormation: Create/update stacks
- Textract: Detect document text
- Bedrock: Invoke foundation models
- SageMaker: Create endpoints, invoke models
- SNS: Publish messages
- SQS: Send/receive messages
- EventBridge: Create rules
- CloudWatch: Create log groups, metrics
- RDS: Create instances (if using RDS)

### Bedrock Model Access

1. Go to AWS Bedrock Console
2. Navigate to "Model access"
3. Request access to:
   - Claude 3 Sonnet
   - Llama 3 (optional)

### SageMaker Setup

1. **Create SageMaker Execution Role**:
```bash
aws iam create-role \
  --role-name SageMakerExecutionRole \
  --assume-role-policy-document file://sagemaker-trust-policy.json
```

2. **Attach Policies**:
```bash
aws iam attach-role-policy \
  --role-name SageMakerExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
```

## Quick Start

### Option 1: Full Automated Deployment

```bash
# 1. Deploy infrastructure
cd infrastructure/cloudformation
aws cloudformation create-stack --stack-name contract-ai-stack --template-body file://main.yaml --capabilities CAPABILITY_NAMED_IAM

# 2. Wait for completion
aws cloudformation wait stack-create-complete --stack-name contract-ai-stack

# 3. Deploy Lambda functions
cd ../../backend
./scripts/deploy.sh

# 4. Deploy frontend
cd ../frontend
npm install
npm run build
aws s3 sync out/ s3://YOUR-BUCKET-NAME
```

### Option 2: Manual Step-by-Step

Follow the detailed deployment guide in `docs/DEPLOYMENT.md`

## Verification

1. **Check Infrastructure**:
```bash
aws cloudformation describe-stacks --stack-name contract-ai-stack
```

2. **List Lambda Functions**:
```bash
aws lambda list-functions --query "Functions[?contains(FunctionName, 'contract-ai')]"
```

3. **Test API Gateway**:
```bash
curl https://YOUR-API-GATEWAY-URL/upload
```

## Next Steps

- Read `docs/ARCHITECTURE.md` for system design
- Review `docs/DEPLOYMENT.md` for production deployment
- Check `README.md` for project overview

