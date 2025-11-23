# ContractIQ - AI-Powered Contract Review & Risk Analysis Platform

## 🚀 Enterprise-Grade SaaS Platform Built on AWS

**ContractIQ** is a production-ready, serverless AI platform that automates contract analysis, clause extraction, risk identification, and intelligent risk scoring. Built entirely on AWS cloud infrastructure with a modern React frontend.

## ✨ Key Features

- **🤖 AI-Powered Analysis**: Leverages AWS Bedrock (Claude 3 Sonnet) for intelligent contract clause extraction and risk identification
- **📄 Multi-Format Support**: Processes PDF contracts using AWS Textract OCR with intelligent fallback mechanisms
- **🎯 Risk Scoring**: Machine learning-powered risk assessment using SageMaker with real-time scoring
- **📊 Interactive Dashboard**: Modern React/Next.js dashboard with real-time contract status tracking
- **🔔 Smart Notifications**: Automated email notifications via SNS when analysis completes
- **🔒 Enterprise Security**: IAM-based access control, encrypted storage, and secure API endpoints

## 🏗️ Architecture

**Serverless & Event-Driven Design:**
- **Frontend**: Next.js 14 with TypeScript, Tailwind CSS
- **API Layer**: AWS API Gateway with Lambda integration
- **Processing Pipeline**: Event-driven architecture with SQS for async processing
- **AI/ML**: AWS Bedrock for NLP, SageMaker for risk scoring
- **Storage**: S3 for documents, DynamoDB for metadata
- **Infrastructure**: CloudFormation for IaC, automated deployments

## 🛠️ Tech Stack

### AWS Services (15+)
- **Compute**: Lambda, API Gateway, EC2 (container builds)
- **Storage**: S3, DynamoDB
- **AI/ML**: Bedrock (Claude 3), Textract, SageMaker, ECR
- **Messaging**: SQS, SNS
- **DevOps**: CloudFormation, CloudWatch, IAM

### Frontend
- Next.js 14, React, TypeScript
- Tailwind CSS
- Axios for API integration

### Backend
- Python 3.9+
- Boto3 (AWS SDK)
- Serverless Lambda functions

## 📋 Workflow

1. **Upload**: Users upload PDF contracts via web interface
2. **Extraction**: Text extraction using Textract/PyPDF2
3. **Analysis**: AI-powered clause extraction and risk identification via Bedrock
4. **Scoring**: ML model calculates risk scores (0-100)
5. **Storage**: Results stored in DynamoDB with full audit trail
6. **Notification**: Email alerts sent via SNS
7. **Dashboard**: Real-time status updates and detailed analysis views

## 🚀 Deployment

- **Infrastructure**: CloudFormation templates for automated provisioning
- **CI/CD**: GitHub Actions workflow for automated deployments
- **Containerization**: Docker containers for SageMaker models
- **Monitoring**: CloudWatch logs and metrics

## 📈 Production Features

- ✅ Scalable serverless architecture
- ✅ High availability with multi-AZ deployment
- ✅ Automated error handling and retries
- ✅ CORS-enabled API endpoints
- ✅ Secure file uploads with validation
- ✅ Real-time processing status tracking
- ✅ Comprehensive logging and monitoring

## 🎯 Use Cases

- Legal departments reviewing vendor contracts
- Procurement teams assessing agreement risks
- Compliance officers identifying regulatory issues
- Business analysts evaluating contract terms

## 📝 Project Structure

```
├── frontend/          # Next.js React application
├── backend/          # Lambda functions and ML models
├── infrastructure/    # CloudFormation templates
└── docs/             # Architecture and API documentation
```

## 🔧 Setup & Installation

See [SETUP.md](docs/SETUP.md) for detailed installation instructions.

## 📄 License

MIT License - See LICENSE file for details

---


