#!/bin/bash

# Deployment script for Lambda functions
# Packages and deploys all Lambda functions to AWS

set -e

PROJECT_NAME="contract-ai"
ENVIRONMENT="${ENVIRONMENT:-dev}"
REGION="${AWS_REGION:-us-east-1}"

echo "Deploying Lambda functions..."

# Function to deploy a Lambda
deploy_lambda() {
    FUNCTION_NAME=$1
    FUNCTION_DIR=$2
    
    echo "Deploying $FUNCTION_NAME..."
    
    cd "$FUNCTION_DIR"
    
    # Create deployment package
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt -t .
    fi
    
    # Create zip file
    zip -r "../${FUNCTION_NAME}.zip" . -x "*.pyc" "__pycache__/*" "*.zip"
    
    # Deploy using AWS CLI
    aws lambda update-function-code \
        --function-name "${PROJECT_NAME}-${FUNCTION_NAME}-${ENVIRONMENT}" \
        --zip-file "fileb://../${FUNCTION_NAME}.zip" \
        --region "$REGION" \
        || aws lambda create-function \
            --function-name "${PROJECT_NAME}-${FUNCTION_NAME}-${ENVIRONMENT}" \
            --runtime python3.9 \
            --role "arn:aws:iam::ACCOUNT:role/${PROJECT_NAME}-lambda-role-${ENVIRONMENT}" \
            --handler lambda_function.lambda_handler \
            --zip-file "fileb://../${FUNCTION_NAME}.zip" \
            --timeout 30 \
            --region "$REGION"
    
    cd - > /dev/null
    
    echo "✓ $FUNCTION_NAME deployed"
}

# Deploy all functions
cd "$(dirname "$0")/../lambdas"

deploy_lambda "upload-handler" "uploadHandler"
deploy_lambda "textract-processor" "textractProcessor"
deploy_lambda "bedrock-analyzer" "bedrockAnalyzer"
deploy_lambda "sagemaker-scorer" "sageMakerScorer"
deploy_lambda "notify-user" "notifyUser"

echo "All Lambda functions deployed successfully!"

