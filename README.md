# ContractIQ - AI-Powered Contract Review & Risk Analysis Platform

## 🚀 Enterprise-Grade SaaS Platform Built on AWS

**ContractIQ** is a production-ready, serverless AI platform that automates contract analysis, clause extraction, risk identification, and intelligent risk scoring. Built entirely on AWS cloud infrastructure with a modern React frontend.

[![AWS](https://img.shields.io/badge/AWS-15%2B%20Services-orange)](https://aws.amazon.com)
[![Serverless](https://img.shields.io/badge/Architecture-Serverless-blue)](https://aws.amazon.com/serverless)
[![React](https://img.shields.io/badge/Frontend-React%2FNext.js-61dafb)](https://reactjs.org)
[![Python](https://img.shields.io/badge/Backend-Python-3776ab)](https://python.org)

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

### Prerequisites
- AWS Account with appropriate permissions
- AWS CLI configured
- Node.js 18+ and npm
- Python 3.9+
- Docker (for SageMaker model deployment)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/MuhammadTalha28/ContractIQ-AI-powered-contract-intelligence.git
   cd ContractIQ-AI-powered-contract-intelligence
   ```

2. **Deploy Infrastructure**
   ```bash
   cd infrastructure/cloudformation
   aws cloudformation create-stack \
     --stack-name contract-ai-infrastructure \
     --template-body file://main.yaml \
     --capabilities CAPABILITY_NAMED_IAM
   ```

3. **Deploy Lambda Functions**
   ```bash
   cd backend
   ./deploy-lambdas.ps1  # Windows PowerShell
   # or
   ./deploy-lambdas.sh   # Linux/Mac
   ```

4. **Setup Frontend**
   ```bash
   cd frontend
   npm install
   cp .env.example .env.local
   # Edit .env.local with your API Gateway URL
   npm run dev
   ```

See [docs/SETUP.md](docs/SETUP.md) for detailed setup instructions.

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
├── backend/           # Lambda functions and ML models
│   ├── lambdas/       # Lambda function code
│   └── models/       # SageMaker ML models
├── infrastructure/    # CloudFormation templates
└── docs/             # Architecture and API documentation
```

## 🔧 Configuration

### Environment Variables

**Frontend** (`frontend/.env.local`):
```env
NEXT_PUBLIC_API_URL=https://YOUR_API_GATEWAY_ID.execute-api.us-east-1.amazonaws.com/dev
```

**Backend** (Lambda environment variables set via CloudFormation):
- `CONTRACTS_TABLE`: DynamoDB table name
- `SAGEMAKER_ENDPOINT_NAME`: SageMaker endpoint name
- `SNS_TOPIC_ARN`: SNS topic for notifications

## 📚 Documentation

- [Architecture Overview](docs/ARCHITECTURE.md)
- [API Documentation](docs/API.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [Setup Instructions](docs/SETUP.md)
- [Security Guidelines](SECURITY.md)

## 🔒 Security

- All credentials use environment variables or AWS Secrets Manager
- IAM roles follow principle of least privilege
- API endpoints protected with CORS
- S3 buckets with encryption enabled
- See [SECURITY.md](SECURITY.md) for details

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details

## 👤 Author

**Muhammad Talha**

- GitHub: [@MuhammadTalha28](https://github.com/MuhammadTalha28)
- Portfolio: [muhammadtalhakhalid.com](https://www.muhammadtalhakhalid.com)

## 🙏 Acknowledgments

- AWS for providing comprehensive cloud services
- Anthropic for Claude 3 via AWS Bedrock
- The open-source community for amazing tools and libraries

---

**Built with ❤️ using AWS Serverless Architecture**

For questions or support, please open an issue on GitHub.
