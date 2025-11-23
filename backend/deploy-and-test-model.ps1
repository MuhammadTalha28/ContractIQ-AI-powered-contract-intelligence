# Deploy and Test SageMaker Model
Write-Host "=== SageMaker Model Deployment & Testing ===" -ForegroundColor Cyan
Write-Host ""

# Check if model exists
Write-Host "Checking if model is already deployed..." -ForegroundColor Yellow
$endpointStatus = aws sagemaker describe-endpoint --endpoint-name contract-risk-scorer-dev --query "EndpointStatus" --output text 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "Endpoint found! Status: $endpointStatus" -ForegroundColor Green
    
    if ($endpointStatus -eq "InService") {
        Write-Host ""
        Write-Host "[OK] Model is already deployed and InService!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Testing the endpoint..." -ForegroundColor Yellow
        .\test-sagemaker-endpoint.ps1
        exit 0
    } else {
        Write-Host ""
        Write-Host "Endpoint is $endpointStatus. Waiting for it to be ready..." -ForegroundColor Yellow
        Write-Host "Check status: aws sagemaker describe-endpoint --endpoint-name contract-risk-scorer-dev" -ForegroundColor White
        exit 0
    }
}

Write-Host "Model not deployed yet." -ForegroundColor Yellow
Write-Host ""
Write-Host "=== DEPLOYMENT INSTRUCTIONS ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Due to ECR repository permissions, deploy via AWS Console:" -ForegroundColor Yellow
Write-Host ""

Write-Host "STEP 1: Create Model" -ForegroundColor Green
Write-Host "1. Open: https://console.aws.amazon.com/sagemaker/home?region=us-east-1#/models" -ForegroundColor Cyan
Write-Host "2. Click 'Create model'" -ForegroundColor White
Write-Host "3. Model name: contract-risk-scorer-dev" -ForegroundColor White
Write-Host "4. IAM role: contract-ai-sagemaker-role-dev" -ForegroundColor White
Write-Host "5. Container definition:" -ForegroundColor White
Write-Host "   - Select 'Use an existing container'" -ForegroundColor Gray
Write-Host "   - Image: 763104351884.dkr.ecr.us-east-1.amazonaws.com/sklearn-inference:1.0-1-cpu-py3" -ForegroundColor Gray
Write-Host "   - Model data source: S3" -ForegroundColor Gray
Write-Host "   - S3 location: s3://contract-ai-models-dev-YOUR_AWS_ACCOUNT_ID/risk-scorer/model.pkl" -ForegroundColor Gray
Write-Host "6. Click 'Create model'" -ForegroundColor White
Write-Host ""

Write-Host "STEP 2: Create Endpoint" -ForegroundColor Green
Write-Host "1. Open: https://console.aws.amazon.com/sagemaker/home?region=us-east-1#/endpoints" -ForegroundColor Cyan
Write-Host "2. Click 'Create endpoint'" -ForegroundColor White
Write-Host "3. Endpoint name: contract-risk-scorer-dev" -ForegroundColor White
Write-Host "4. Endpoint configuration: Create new" -ForegroundColor White
Write-Host "   - Name: contract-risk-scorer-dev-config" -ForegroundColor Gray
Write-Host "   - Model: contract-risk-scorer-dev" -ForegroundColor Gray
Write-Host "   - Variant name: AllTraffic" -ForegroundColor Gray
Write-Host "   - Instance type: ml.t2.medium" -ForegroundColor Gray
Write-Host "   - Initial instance count: 1" -ForegroundColor Gray
Write-Host "5. Click 'Create endpoint' (takes 5-10 minutes)" -ForegroundColor White
Write-Host ""

Write-Host "STEP 3: Wait for Deployment" -ForegroundColor Green
Write-Host "Monitor status with:" -ForegroundColor Yellow
Write-Host "  aws sagemaker describe-endpoint --endpoint-name contract-risk-scorer-dev --query 'EndpointStatus'" -ForegroundColor White
Write-Host ""

Write-Host "STEP 4: Test Once InService" -ForegroundColor Green
Write-Host "Run: .\test-sagemaker-endpoint.ps1" -ForegroundColor Yellow
Write-Host ""

