# Fix CORS OPTIONS method
$REST_API_ID = "YOUR_API_GATEWAY_ID"
$UPLOAD_RESOURCE_ID = "2ry9z7"

Write-Host "=== Fixing CORS OPTIONS Method ===" -ForegroundColor Cyan
Write-Host ""

# Create OPTIONS method
Write-Host "1. Creating OPTIONS method..." -ForegroundColor Yellow
aws apigateway put-method --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --authorization-type NONE --no-api-key-required 2>&1 | Out-Null

# Create MOCK integration
Write-Host "2. Creating MOCK integration..." -ForegroundColor Yellow
aws apigateway put-integration --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --type MOCK --request-templates '{"application/json":"{\"statusCode\":200}"}' 2>&1 | Out-Null

# Integration response with CORS headers
Write-Host "3. Configuring CORS headers..." -ForegroundColor Yellow
aws apigateway put-integration-response --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Headers":"'"'"'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"'"'","method.response.header.Access-Control-Allow-Methods":"'"'"'POST,OPTIONS'"'"'","method.response.header.Access-Control-Allow-Origin":"'"'"'*'"'"'"}' --response-templates '{"application/json":""}' 2>&1 | Out-Null

# Method response
Write-Host "4. Setting method response..." -ForegroundColor Yellow
aws apigateway put-method-response --rest-api-id $REST_API_ID --resource-id $UPLOAD_RESOURCE_ID --http-method OPTIONS --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Headers":false,"method.response.header.Access-Control-Allow-Methods":false,"method.response.header.Access-Control-Allow-Origin":false}' 2>&1 | Out-Null

# Redeploy
Write-Host "5. Redeploying API..." -ForegroundColor Yellow
aws apigateway create-deployment --rest-api-id $REST_API_ID --stage-name dev --description "CORS fix" 2>&1 | Out-Null

Write-Host ""
Write-Host "[SUCCESS] CORS OPTIONS method configured!" -ForegroundColor Green
Write-Host "Try uploading again in the browser." -ForegroundColor Yellow

