# Legal AI Contract Analyzer (Enterprise Edition)

A cloud-based SaaS platform that automatically analyzes contracts, extracts clauses, identifies risks, and provides comprehensive summaries using AWS AI/ML services.

## Architecture Overview

```
Frontend (Next.js) → API Gateway → Lambda Functions → AWS Services
                                                      ├── S3 (Storage)
                                                      ├── DynamoDB (Metadata)
                                                      ├── RDS (Users)
                                                      ├── Textract (OCR)
                                                      ├── Bedrock (LLM Analysis)
                                                      ├── SageMaker (ML Risk Scoring)
                                                      └── SNS (Notifications)
```

## AWS Services Used

- **EC2**: Optional PDF preprocessor/background workers
- **Lambda**: Contract processing logic, Bedrock calls, data persistence
- **API Gateway**: REST API endpoints
- **S3**: Document storage and extracted text
- **CloudFront**: CDN for frontend
- **IAM**: Service roles and permissions
- **DynamoDB**: Contract metadata, clauses, AI results
- **RDS (PostgreSQL)**: User accounts, subscriptions, authentication
- **VPC**: Secure networking for RDS and EC2
- **CloudWatch**: Logging and monitoring
- **SQS**: Async task queue
- **SNS**: Email notifications
- **Bedrock**: Claude 3 / Llama 3 for clause extraction
- **SageMaker**: ML risk classifier (0-100 scoring)
- **EventBridge**: Event-driven pipeline triggers
- **CodePipeline**: CI/CD automation

## Project Structure

```
aws-contract-ai/
├── frontend/              # Next.js React application
├── backend/
│   ├── lambdas/          # Lambda function handlers
│   ├── api-gateway/      # API Gateway definitions
│   ├── models/           # SageMaker ML models
│   └── scripts/          # Utility scripts
├── infrastructure/
│   ├── cloudformation/   # CloudFormation templates
│   └── iam-roles/        # IAM role definitions
├── terraform/            # Terraform configurations (optional)
└── docs/                 # Documentation

```

## Getting Started

### Prerequisites

- AWS Account with appropriate permissions
- Node.js 18+ and npm
- Python 3.9+
- AWS CLI configured
- Terraform (optional, for IaC)

### Setup Instructions

1. **Configure AWS Credentials**
   ```bash
   aws configure
   ```

2. **Deploy Infrastructure**
   ```bash
   cd infrastructure/cloudformation
   aws cloudformation deploy --template-file main.yaml --stack-name contract-ai-stack
   ```

3. **Deploy Backend**
   ```bash
   cd backend
   ./scripts/deploy.sh
   ```

4. **Run Frontend**
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

## Development Phases

- [x] Phase 1: Setup & Basic Skeleton
- [ ] Phase 2: OCR + Extraction Pipeline
- [ ] Phase 3: LLM Analysis with Bedrock
- [ ] Phase 4: ML Model on SageMaker
- [ ] Phase 5: Database Setup
- [ ] Phase 6: Notifications
- [ ] Phase 7: Monitoring + Logs
- [ ] Phase 8: CI/CD Deployment
- [ ] Phase 9: CloudFront Hosting

## License

MIT

