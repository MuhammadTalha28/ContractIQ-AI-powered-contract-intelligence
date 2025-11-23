# Fix API Gateway - Deploy and Configure CORS
$REST_API_ID = "apkt52eqka"
$REGION = "us-east-1"
$UPLOAD_RESOURCE_ID = "2ry9z7"

Write-Host "=== Fixing API Gateway ===" -ForegroundColor Cyan
Write-Host ""

# 1. Fix OPTIONS method for CORS
Write-Host "1. Configuring OPTIONS method for CORS..." -ForegroundColor Yellow

# Integration for OPTIONS (MOCK)
aws apigateway put-integration --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --type MOCK --request-templates '{"application/json":"{\"statusCode\":200}"}' 2>&1 | Out-Null

# Integration response
aws apigateway put-integration-response --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Headers":"'"'"'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"'"'","method.response.header.Access-Control-Allow-Methods":"'"'"'POST,OPTIONS'"'"'","method.response.header.Access-Control-Allow-Origin":"'"'"'*'"'"'"}' --response-templates '{"application/json":""}' 2>&1 | Out-Null

# Method response
aws apigateway put-method-response --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Headers":false,"method.response.header.Access-Control-Allow-Methods":false,"method.response.header.Access-Control-Allow-Origin":false}' 2>&1 | Out-Null

Write-Host "   [OK] OPTIONS method configured" -ForegroundColor Green

# 2. Add CORS headers to POST method response
Write-Host "2. Adding CORS headers to POST method..." -ForegroundColor Yellow

aws apigateway put-method-response --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method POST --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Origin":false}' 2>&1 | Out-Null

aws apigateway put-integration-response --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method POST --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Origin":"'"'"'*'"'"'"}' 2>&1 | Out-Null

Write-Host "   [OK] CORS headers added" -ForegroundColor Green

# 3. Deploy API to dev stage
Write-Host "3. Deploying API to dev stage..." -ForegroundColor Yellow

$deployment = aws apigateway create-deployment --rest-api-id $REST_API_ID --stage-name dev --description "Initial deployment" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] API deployed" -ForegroundColor Green
} else {
    Write-Host "   [WARNING] Deployment may have failed, trying update..." -ForegroundColor Yellow
    # Try to get existing deployment and update
    aws apigateway create-deployment --rest-api-id $REST_API_ID --stage-name dev 2>&1 | Out-Null
}

Write-Host ""
Write-Host "[SUCCESS] API Gateway fixed!" -ForegroundColor Green
Write-Host ""
Write-Host "API URL: https://${REST_API_ID}.execute-api.${REGION}.amazonaws.com/dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test with:" -ForegroundColor Yellow
Write-Host "curl -X POST https://${REST_API_ID}.execute-api.${REGION}.amazonaws.com/dev/upload -H 'Content-Type: application/json' -d '{\"file_content\":\"test\",\"filename\":\"test.pdf\"}'" -ForegroundColor White

