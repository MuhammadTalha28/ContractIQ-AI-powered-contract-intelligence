# Setup API Gateway for Frontend Connection
$REST_API_ID = "YOUR_API_GATEWAY_ID"
$REGION = "us-east-1"
$UPLOAD_LAMBDA_ARN = "arn:aws:lambda:us-east-1:YOUR_AWS_ACCOUNT_ID:function:contract-ai-upload-handler-dev"

Write-Host "=== Setting up API Gateway ===" -ForegroundColor Cyan
Write-Host ""

# Get root resource ID
$rootResource = aws apigateway get-resources --rest-api-id $REST_API_ID --query "items[?path=='/'].id" --output text
Write-Host "Root resource ID: $rootResource" -ForegroundColor Yellow

# Create /upload resource
Write-Host "Creating /upload resource..." -ForegroundColor Yellow
$uploadResource = aws apigateway create-resource --rest-api-id $REST_API_ID --parent-id $rootResource --path-part "upload" --query "id" --output text
Write-Host "Upload resource ID: $uploadResource" -ForegroundColor Green

# Create POST method for /upload
Write-Host "Creating POST method..." -ForegroundColor Yellow
aws apigateway put-method --rest-api-id $REST_API_ID --resource-id $uploadResource --http-method POST --authorization-type NONE --no-api-key-required 2>&1 | Out-Null

# Set up Lambda integration
Write-Host "Setting up Lambda integration..." -ForegroundColor Yellow
aws apigateway put-integration --rest-api-id $REST_API_ID --resource-id $uploadResource --http-method POST --type AWS_PROXY --integration-http-method POST --uri "arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${UPLOAD_LAMBDA_ARN}/invocations" 2>&1 | Out-Null

# Add Lambda permission
Write-Host "Adding Lambda permission..." -ForegroundColor Yellow
aws lambda add-permission --function-name contract-ai-upload-handler-dev --statement-id apigateway-invoke --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn "arn:aws:execute-api:${REGION}:YOUR_AWS_ACCOUNT_ID:${REST_API_ID}/*/*" 2>&1 | Out-Null

# Enable CORS
Write-Host "Enabling CORS..." -ForegroundColor Yellow
aws apigateway put-method-response --rest-api-id $REST_API_ID --resource-id $uploadResource --http-method OPTIONS --status-code 200 --response-parameters "method.response.header.Access-Control-Allow-Headers=false,method.response.header.Access-Control-Allow-Methods=false,method.response.header.Access-Control-Allow-Origin=false" 2>&1 | Out-Null

# Create OPTIONS method for CORS
aws apigateway put-method --rest-api-id $REST_API_ID --resource-id $uploadResource --http-method OPTIONS --authorization-type NONE --no-api-key-required 2>&1 | Out-Null

# Deploy API
Write-Host "Deploying API..." -ForegroundColor Yellow
aws apigateway create-deployment --rest-api-id $REST_API_ID --stage-name dev 2>&1 | Out-Null

# Get API URL
$API_URL = "https://${REST_API_ID}.execute-api.${REGION}.amazonaws.com/dev"
Write-Host ""
Write-Host "[SUCCESS] API Gateway configured!" -ForegroundColor Green
Write-Host ""
Write-Host "API URL: $API_URL" -ForegroundColor Cyan
Write-Host ""
Write-Host "Add this to frontend/.env.local:" -ForegroundColor Yellow
Write-Host "NEXT_PUBLIC_API_URL=$API_URL" -ForegroundColor White

