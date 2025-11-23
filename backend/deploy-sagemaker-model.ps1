# Deploy SageMaker Model
$MODEL_BUCKET = "contract-ai-models-dev-YOUR_AWS_ACCOUNT_ID"
$MODEL_NAME = "contract-risk-scorer-$(Get-Date -Format 'yyyyMMdd')"
$ENDPOINT_NAME = "contract-risk-scorer-dev"

Write-Host "=== Deploying SageMaker Model ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Create model
Write-Host "1. Creating SageMaker model..." -ForegroundColor Yellow
$IMAGE_URI = "763104351884.dkr.ecr.us-east-1.amazonaws.com/sklearn-inference:1.0-1-cpu-py3"

$SAGEMAKER_ROLE = "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/contract-ai-sagemaker-role-dev"
$modelResponse = aws sagemaker create-model --model-name $MODEL_NAME --execution-role-arn $SAGEMAKER_ROLE --primary-container "Image=$IMAGE_URI,ModelDataUrl=s3://$MODEL_BUCKET/risk-scorer/model.pkl" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Model created: $MODEL_NAME" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] $modelResponse" -ForegroundColor Red
    exit 1
}

# Step 2: Create endpoint configuration
Write-Host "2. Creating endpoint configuration..." -ForegroundColor Yellow
$configResponse = aws sagemaker create-endpoint-config --endpoint-config-name "${ENDPOINT_NAME}-config" --production-variants "VariantName=AllTraffic,ModelName=$MODEL_NAME,InitialInstanceCount=1,InstanceType=ml.t2.medium" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Endpoint config created" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] $configResponse" -ForegroundColor Red
    exit 1
}

# Step 3: Create endpoint
Write-Host "3. Creating endpoint (this takes 5-10 minutes)..." -ForegroundColor Yellow
$endpointResponse = aws sagemaker create-endpoint --endpoint-name $ENDPOINT_NAME --endpoint-config-name "${ENDPOINT_NAME}-config" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Endpoint creation started" -ForegroundColor Green
    Write-Host "   Endpoint: $ENDPOINT_NAME" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Waiting for endpoint to be ready..." -ForegroundColor Yellow
    Write-Host "Check status with: aws sagemaker describe-endpoint --endpoint-name $ENDPOINT_NAME" -ForegroundColor White
} else {
    Write-Host "   [ERROR] $endpointResponse" -ForegroundColor Red
}

Write-Host ""
Write-Host "[DONE] Model deployment initiated" -ForegroundColor Green

