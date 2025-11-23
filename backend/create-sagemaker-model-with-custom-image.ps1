# Create SageMaker Model with Custom ECR Image
Write-Host "=== Creating SageMaker Model with Custom Container ===" -ForegroundColor Cyan
Write-Host ""

$MODEL_NAME = "contract-risk-scorer-dev"
$IMAGE_URI = "YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/risk-scorer:latest"
$MODEL_DATA = "s3://contract-ai-models-dev-YOUR_AWS_ACCOUNT_ID/risk-scorer/model.pkl"
$ROLE_ARN = "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/contract-ai-sagemaker-role-dev"

Write-Host "Model Configuration:" -ForegroundColor Yellow
Write-Host "  Name: $MODEL_NAME" -ForegroundColor White
Write-Host "  Image: $IMAGE_URI" -ForegroundColor White
Write-Host "  Model Data: $MODEL_DATA" -ForegroundColor White
Write-Host "  Role: $ROLE_ARN" -ForegroundColor White
Write-Host ""

# Check if model already exists
Write-Host "Step 1: Checking if model exists..." -ForegroundColor Yellow
$existing = aws sagemaker describe-model --model-name $MODEL_NAME 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   [INFO] Model already exists. Updating..." -ForegroundColor Yellow
    # Delete existing model first
    aws sagemaker delete-model --model-name $MODEL_NAME 2>&1 | Out-Null
    Start-Sleep -Seconds 2
}

# Create model
Write-Host "`nStep 2: Creating SageMaker model..." -ForegroundColor Yellow
$modelResponse = aws sagemaker create-model `
    --model-name $MODEL_NAME `
    --execution-role-arn $ROLE_ARN `
    --primary-container "Image=$IMAGE_URI,ModelDataUrl=$MODEL_DATA" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Model created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Model ARN:" -ForegroundColor Cyan
    ($modelResponse | ConvertFrom-Json).ModelArn
} else {
    Write-Host "   [ERROR] Failed to create model" -ForegroundColor Red
    Write-Host "   $modelResponse" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Yellow
Write-Host "1. Create endpoint configuration:" -ForegroundColor White
Write-Host "   aws sagemaker create-endpoint-config --endpoint-config-name contract-risk-scorer-dev-config --production-variants VariantName=AllTraffic,ModelName=$MODEL_NAME,InitialInstanceCount=1,InstanceType=ml.t2.medium" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Create endpoint:" -ForegroundColor White
Write-Host "   aws sagemaker create-endpoint --endpoint-name contract-risk-scorer-dev --endpoint-config-name contract-risk-scorer-dev-config" -ForegroundColor Gray
Write-Host ""
Write-Host "Or use the console: https://console.aws.amazon.com/sagemaker/home?region=us-east-1#/endpoints" -ForegroundColor Cyan

