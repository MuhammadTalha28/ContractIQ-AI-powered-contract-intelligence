# Complete CORS Fix
$REST_API_ID = "YOUR_API_GATEWAY_ID"
$UPLOAD_RESOURCE_ID = "2ry9z7"

Write-Host "=== Complete CORS Fix ===" -ForegroundColor Cyan
Write-Host ""

# Delete and recreate OPTIONS method
Write-Host "1. Removing broken OPTIONS method..." -ForegroundColor Yellow
aws apigateway delete-method --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS 2>&1 | Out-Null
Start-Sleep -Seconds 1

# Create OPTIONS method
Write-Host "2. Creating OPTIONS method..." -ForegroundColor Yellow
aws apigateway put-method --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --authorization-type NONE --no-api-key-required 2>&1 | Out-Null

# Create MOCK integration
Write-Host "3. Creating MOCK integration..." -ForegroundColor Yellow
aws apigateway put-integration --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --type MOCK --request-templates '{"application/json":"{\"statusCode\":200}"}' 2>&1 | Out-Null

# Method response FIRST (required before integration response)
Write-Host "4. Setting method response..." -ForegroundColor Yellow
aws apigateway put-method-response --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Headers":false,"method.response.header.Access-Control-Allow-Methods":false,"method.response.header.Access-Control-Allow-Origin":false}' 2>&1 | Out-Null

# Integration response
Write-Host "5. Setting integration response with CORS headers..." -ForegroundColor Yellow
aws apigateway put-integration-response --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Headers":"'"'"'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"'"'","method.response.header.Access-Control-Allow-Methods":"'"'"'POST,OPTIONS'"'"'","method.response.header.Access-Control-Allow-Origin":"'"'"'*'"'"'"}' --response-templates '{"application/json":""}' 2>&1 | Out-Null

# Verify
Write-Host "6. Verifying integration..." -ForegroundColor Yellow
$integration = aws apigateway get-integration --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --query "type" --output text 2>&1
if ($integration -eq "MOCK") {
    Write-Host "   [OK] Integration verified" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] Integration not found: $integration" -ForegroundColor Red
}

# Deploy
Write-Host "7. Deploying API..." -ForegroundColor Yellow
$deploy = aws apigateway create-deployment --rest-api-id $REST_API_ID --stage-name dev --description "CORS complete fix $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Deployed" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] $deploy" -ForegroundColor Red
}

Write-Host ""
Write-Host "[DONE] CORS should be fixed now!" -ForegroundColor Green
Write-Host "Refresh browser and try again." -ForegroundColor Yellow

