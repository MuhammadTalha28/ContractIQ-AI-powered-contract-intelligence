# Monitor SageMaker endpoint and test when ready
Write-Host "=== SageMaker Model Monitor & Test ===" -ForegroundColor Cyan
Write-Host ""

$ENDPOINT_NAME = "contract-risk-scorer-dev"
$MAX_WAIT_MINUTES = 15
$CHECK_INTERVAL = 30  # seconds

Write-Host "Monitoring endpoint: $ENDPOINT_NAME" -ForegroundColor Yellow
Write-Host "Checking every $CHECK_INTERVAL seconds..." -ForegroundColor Gray
Write-Host ""

$startTime = Get-Date
$maxWaitTime = $startTime.AddMinutes($MAX_WAIT_MINUTES)

while ($true) {
    $status = aws sagemaker describe-endpoint --endpoint-name $ENDPOINT_NAME --query "EndpointStatus" --output text 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        if ($status -match "does not exist" -or $status -match "ResourceNotFound") {
            Write-Host "[INFO] Endpoint not found. Please deploy via AWS Console first." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Quick deployment steps:" -ForegroundColor Cyan
            Write-Host "1. Models: https://console.aws.amazon.com/sagemaker/home?region=us-east-1#/models" -ForegroundColor White
            Write-Host "   - Create model: contract-risk-scorer-dev" -ForegroundColor Gray
            Write-Host "   - Role: contract-ai-sagemaker-role-dev" -ForegroundColor Gray
            Write-Host "   - Image: 763104351884.dkr.ecr.us-east-1.amazonaws.com/sklearn-inference:1.0-1-cpu-py3" -ForegroundColor Gray
            Write-Host "   - Model data: s3://contract-ai-models-dev-YOUR_AWS_ACCOUNT_ID/risk-scorer/model.pkl" -ForegroundColor Gray
            Write-Host ""
            Write-Host "2. Endpoints: https://console.aws.amazon.com/sagemaker/home?region=us-east-1#/endpoints" -ForegroundColor White
            Write-Host "   - Create endpoint: contract-risk-scorer-dev" -ForegroundColor Gray
            Write-Host "   - Use model: contract-risk-scorer-dev" -ForegroundColor Gray
            Write-Host "   - Instance: ml.t2.medium" -ForegroundColor Gray
            Write-Host ""
            Write-Host "Then run this script again to monitor and test." -ForegroundColor Yellow
        } else {
            Write-Host "[ERROR] $status" -ForegroundColor Red
        }
        break
    }
    
    $elapsed = [int]((Get-Date) - $startTime).TotalSeconds
    $statusColor = switch ($status) {
        "InService" { "Green" }
        "Creating" { "Yellow" }
        "Updating" { "Yellow" }
        "Failed" { "Red" }
        default { "White" }
    }
    
    Write-Host "[$elapsed s] Status: $status" -ForegroundColor $statusColor
    
    if ($status -eq "InService") {
        Write-Host ""
        Write-Host "[SUCCESS] Endpoint is InService!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Testing endpoint..." -ForegroundColor Yellow
        .\test-sagemaker-endpoint.ps1
        break
    } elseif ($status -eq "Failed") {
        Write-Host ""
        Write-Host "[ERROR] Endpoint deployment failed!" -ForegroundColor Red
        $details = aws sagemaker describe-endpoint --endpoint-name $ENDPOINT_NAME --query "FailureReason" --output text
        Write-Host "Reason: $details" -ForegroundColor Red
        break
    }
    
    if ((Get-Date) -gt $maxWaitTime) {
        Write-Host ""
        Write-Host "[WARNING] Timeout after $MAX_WAIT_MINUTES minutes" -ForegroundColor Yellow
        Write-Host "Endpoint is still: $status" -ForegroundColor Yellow
        Write-Host "Continue monitoring manually or check console." -ForegroundColor White
        break
    }
    
    Start-Sleep -Seconds $CHECK_INTERVAL
}

Write-Host ""

