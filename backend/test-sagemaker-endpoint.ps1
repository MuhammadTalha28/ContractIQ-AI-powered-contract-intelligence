# Test SageMaker Endpoint
Write-Host "=== Testing SageMaker Endpoint ===" -ForegroundColor Cyan
Write-Host ""

$ENDPOINT_NAME = "contract-risk-scorer-dev"

# Check endpoint status
Write-Host "1. Checking endpoint status..." -ForegroundColor Yellow
$status = aws sagemaker describe-endpoint --endpoint-name $ENDPOINT_NAME --query "EndpointStatus" --output text 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "   [ERROR] Endpoint not found. Deploy it first." -ForegroundColor Red
    Write-Host "   Run: .\deploy-and-test-model.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "   Status: $status" -ForegroundColor $(if ($status -eq "InService") { "Green" } else { "Yellow" })

if ($status -ne "InService") {
    Write-Host ""
    Write-Host "   [WARNING] Endpoint is not InService yet." -ForegroundColor Yellow
    Write-Host "   Wait for deployment to complete, then test again." -ForegroundColor White
    exit 1
}

# Test with sample features
Write-Host ""
Write-Host "2. Testing endpoint with sample features..." -ForegroundColor Yellow

# Sample feature vector: clauses_count, risky_keywords, missing_clauses, hidden_risks, has_penalties, liability_score
$testFeatures = "10,5,2,3,1,0.7"  # Example: 10 clauses, 5 risky keywords, 2 missing, 3 hidden risks, has penalties, 0.7 liability

Write-Host "   Input features: $testFeatures" -ForegroundColor White
Write-Host "   (clauses_count, risky_keywords, missing_clauses, hidden_risks, has_penalties, liability_score)" -ForegroundColor Gray

$response = aws sagemaker-runtime invoke-endpoint `
    --endpoint-name $ENDPOINT_NAME `
    --content-type "text/csv" `
    --body $testFeatures `
    response.json 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Endpoint invoked successfully" -ForegroundColor Green
    
    $result = Get-Content response.json | ConvertFrom-Json
    $riskScore = $result.predictions[0]
    
    Write-Host ""
    Write-Host "3. Results:" -ForegroundColor Yellow
    Write-Host "   Risk Score: $riskScore" -ForegroundColor Cyan
    
    if ($riskScore -ge 70) {
        $level = "HIGH"
        $color = "Red"
    } elseif ($riskScore -ge 40) {
        $level = "MEDIUM"
        $color = "Yellow"
    } else {
        $level = "LOW"
        $color = "Green"
    }
    
    Write-Host "   Risk Level: $level" -ForegroundColor $color
    Write-Host ""
    Write-Host "[SUCCESS] Model is working!" -ForegroundColor Green
    
    # Cleanup
    Remove-Item response.json -ErrorAction SilentlyContinue
} else {
    Write-Host "   [ERROR] Failed to invoke endpoint" -ForegroundColor Red
    Write-Host "   $response" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "4. Testing with Lambda function..." -ForegroundColor Yellow

# Test by uploading a contract
Write-Host "   Upload a contract to test the full pipeline:" -ForegroundColor White
Write-Host "   .\test-with-pdf.ps1" -ForegroundColor Cyan
Write-Host ""

