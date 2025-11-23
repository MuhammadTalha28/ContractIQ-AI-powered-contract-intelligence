# Create and Deploy SageMaker Model
Write-Host "=== Creating SageMaker Model ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Train model locally
Write-Host "1. Training model..." -ForegroundColor Yellow
cd models
python train_sagemaker.py
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Model training failed" -ForegroundColor Red
    exit 1
}

# Step 2: Create S3 bucket for model artifacts (if needed)
$MODEL_BUCKET = "contract-ai-models-dev-YOUR_AWS_ACCOUNT_ID"
Write-Host "2. Preparing model artifacts..." -ForegroundColor Yellow
aws s3 mb s3://$MODEL_BUCKET 2>&1 | Out-Null

# Step 3: Upload model to S3
Write-Host "3. Uploading model to S3..." -ForegroundColor Yellow
if (Test-Path "model.pkl") {
    aws s3 cp model.pkl "s3://$MODEL_BUCKET/risk-scorer/model.pkl"
    Write-Host "   [OK] Model uploaded" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] model.pkl not found" -ForegroundColor Red
    exit 1
}

# Step 4: Create SageMaker model
Write-Host "4. Creating SageMaker model..." -ForegroundColor Yellow
$MODEL_NAME = "contract-risk-scorer-$(Get-Date -Format 'yyyyMMddHHmmss')"
$IMAGE_URI = "763104351884.dkr.ecr.us-east-1.amazonaws.com/sklearn-inference:1.0-1-cpu-py3"

# Create model package
aws sagemaker create-model --model-name $MODEL_NAME --execution-role-arn "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/contract-ai-lambda-role-dev" --primary-container "Image=$IMAGE_URI,ModelDataUrl=s3://$MODEL_BUCKET/risk-scorer/model.pkl" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Model created: $MODEL_NAME" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] Model creation failed" -ForegroundColor Red
    Write-Host "   Using fallback scoring instead" -ForegroundColor Yellow
}

cd ..
Write-Host ""
Write-Host "[DONE]" -ForegroundColor Green

