# Architecture Documentation

## System Overview

The Legal AI Contract Analyzer is a serverless, event-driven architecture built on AWS that processes contracts through multiple stages of analysis.

## Architecture Diagram

```
┌─────────────┐
│   Frontend  │ (Next.js on CloudFront)
│  (React)    │
└──────┬──────┘
       │ HTTPS
       ▼
┌─────────────┐
│ API Gateway │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Lambda    │ Upload Handler
│  Function   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│     S3      │ Contract Storage
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ EventBridge │ Trigger on S3 Upload
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Lambda    │ Textract Processor
│  Function   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Textract   │ OCR Extraction
└──────┬──────┘
       │
       ▼
┌─────────────┐
│     SQS     │ Async Queue
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Lambda    │ Bedrock Analyzer
│  Function   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Bedrock   │ Claude 3 Analysis
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Lambda    │ SageMaker Scorer
│  Function   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  SageMaker  │ ML Risk Scoring
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  DynamoDB   │ Store Results
│     RDS     │ User Data
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Lambda    │ Notify User
│  Function   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│     SNS     │ Email Notification
└─────────────┘
```

## Data Flow

### 1. Upload Phase
- User uploads PDF via frontend
- API Gateway receives request
- Upload Handler Lambda saves to S3
- Contract record created in DynamoDB

### 2. Processing Phase
- EventBridge detects S3 upload
- Triggers Textract Processor Lambda
- Textract extracts text from PDF
- Text saved to S3
- Message sent to SQS queue

### 3. Analysis Phase
- Bedrock Analyzer Lambda processes from SQS
- Calls Bedrock (Claude 3) for clause extraction
- Results saved to DynamoDB

### 4. Scoring Phase
- SageMaker Scorer Lambda calculates risk score
- Calls SageMaker endpoint with features
- Risk score (0-100) saved to DynamoDB

### 5. Notification Phase
- Notify User Lambda sends SNS message
- User receives email notification
- Results available in dashboard

## AWS Services Used

| Service | Purpose | Phase |
|---------|---------|-------|
| **S3** | Document storage | All |
| **Lambda** | Serverless compute | All |
| **API Gateway** | REST API | Upload |
| **EventBridge** | Event routing | Processing |
| **Textract** | OCR extraction | Processing |
| **SQS** | Async queue | Analysis |
| **Bedrock** | LLM analysis | Analysis |
| **SageMaker** | ML risk scoring | Scoring |
| **DynamoDB** | Metadata storage | All |
| **RDS** | User database | All |
| **SNS** | Notifications | Notification |
| **CloudWatch** | Monitoring | All |
| **CloudFront** | CDN | Frontend |
| **IAM** | Permissions | All |

## Security

- All S3 buckets have public access blocked
- IAM roles follow principle of least privilege
- API Gateway uses CORS for frontend access
- DynamoDB tables use on-demand billing
- VPC for RDS isolation (if needed)

## Scalability

- Serverless architecture auto-scales
- SQS provides async processing buffer
- DynamoDB on-demand handles variable load
- CloudFront CDN for global frontend delivery

## Cost Optimization

- Lambda pay-per-use pricing
- DynamoDB on-demand billing
- S3 lifecycle policies (optional)
- CloudWatch log retention limits
- SageMaker endpoint auto-scaling

## Monitoring

- CloudWatch Logs for all Lambda functions
- CloudWatch Metrics for API Gateway
- CloudWatch Alarms for errors
- X-Ray tracing (optional)

