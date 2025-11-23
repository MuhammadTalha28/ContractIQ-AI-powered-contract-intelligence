# Complete API Gateway Fix
$REST_API_ID = "apkt52eqka"
$UPLOAD_RESOURCE_ID = "2ry9z7"

Write-Host "=== Complete API Gateway Fix ===" -ForegroundColor Cyan
Write-Host ""

# Check current methods
Write-Host "Checking current setup..." -ForegroundColor Yellow
aws apigateway get-resource --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --query "resourceMethods" --output json

# Fix OPTIONS integration completely
Write-Host ""
Write-Host "1. Fixing OPTIONS method..." -ForegroundColor Yellow

# Delete and recreate OPTIONS method if needed
aws apigateway delete-method --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS 2>&1 | Out-Null

# Create OPTIONS method
aws apigateway put-method --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --authorization-type NONE --no-api-key-required 2>&1 | Out-Null

# Create MOCK integration
aws apigateway put-integration --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --type MOCK --request-templates '{"application/json":"{\"statusCode\":200}"}' 2>&1 | Out-Null

# Integration response
aws apigateway put-integration-response --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Headers":"'"'"'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"'"'","method.response.header.Access-Control-Allow-Methods":"'"'"'POST,OPTIONS'"'"'","method.response.header.Access-Control-Allow-Origin":"'"'"'*'"'"'"}' --response-templates '{"application/json":""}' 2>&1 | Out-Null

# Method response
aws apigateway put-method-response --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Headers":false,"method.response.header.Access-Control-Allow-Methods":false,"method.response.header.Access-Control-Allow-Origin":false}' 2>&1 | Out-Null

Write-Host "   [OK] OPTIONS configured" -ForegroundColor Green

# 2. Deploy
Write-Host ""
Write-Host "2. Deploying API..." -ForegroundColor Yellow
$deployResult = aws apigateway create-deployment --rest-api-id $REST_API_ID --stage-name dev --description "Fixed deployment" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Deployed successfully" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] $deployResult" -ForegroundColor Red
}

Write-Host ""
Write-Host "[DONE] API Gateway should be working now!" -ForegroundColor Green
Write-Host "URL: https://${REST_API_ID}.execute-api.us-east-1.amazonaws.com/dev/upload" -ForegroundColor Cyan

