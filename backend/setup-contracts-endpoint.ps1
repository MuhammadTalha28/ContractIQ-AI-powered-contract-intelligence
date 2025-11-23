# Add /contracts endpoint to API Gateway
$REST_API_ID = "apkt52eqka"
$REGION = "us-east-1"
$rootResource = "eug178qxw1"

Write-Host "Creating /contracts resource..." -ForegroundColor Yellow
$contractsResource = aws apigateway create-resource --rest-api-id $REST_API_ID --parent-id $rootResource --path-part "contracts" --query "id" --output text

Write-Host "Creating GET method..." -ForegroundColor Yellow
aws apigateway put-method --rest-api-id $REST_API_ID --resource-id $contractsResource --http-method GET --authorization-type NONE --no-api-key-required 2>&1 | Out-Null

# For now, use a simple integration that returns mock data
# In production, connect to a Lambda that queries DynamoDB
$mockResponse = '{"statusCode":200,"headers":{"Content-Type":"application/json","Access-Control-Allow-Origin":"*"},"body":"[]"}'

aws apigateway put-integration --rest-api-id $REST_API_ID --resource-id $contractsResource --http-method GET --type MOCK --request-templates '{"application/json":"{\"statusCode\":200}"}' 2>&1 | Out-Null

aws apigateway put-integration-response --rest-api-id $REST_API_ID --resource-id $contractsResource --http-method GET --status-code 200 --response-templates '{"application/json":"[]"}' 2>&1 | Out-Null

aws apigateway put-method-response --rest-api-id $REST_API_ID --resource-id $contractsResource --http-method GET --status-code 200 --response-parameters "method.response.header.Access-Control-Allow-Origin=false" 2>&1 | Out-Null

Write-Host "Redeploying API..." -ForegroundColor Yellow
aws apigateway create-deployment --rest-api-id $REST_API_ID --stage-name dev 2>&1 | Out-Null

Write-Host "[SUCCESS] /contracts endpoint added!" -ForegroundColor Green

