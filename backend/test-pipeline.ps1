# Test Pipeline and Monitor Logs
Write-Host "=== Testing Contract AI Pipeline ===" -ForegroundColor Cyan
Write-Host ""

$QUEUE_URL = "https://sqs.us-east-1.amazonaws.com/024441264322/contract-ai-processing-dev"
$TEXTRACT_BUCKET = "contract-ai-textract-dev-024441264322"
$CONTRACT_ID = "contract5.pdf"
$TEXT_KEY = "extracted-text/$CONTRACT_ID/text.txt"

# Step 1: Check if text file exists in S3
Write-Host "Step 1: Checking if extracted text exists in S3..." -ForegroundColor Yellow
aws s3 ls "s3://$TEXTRACT_BUCKET/$TEXT_KEY" 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Text file exists in S3" -ForegroundColor Green
} else {
    Write-Host "[INFO] Text file NOT found. Creating a test text file..." -ForegroundColor Yellow
    $testText = "This is a test contract document. It contains payment terms of 10000 per month. Liability is limited to the contract value. Confidentiality clause requires non-disclosure for 2 years. Termination requires 30 days notice."
    $testText | aws s3 cp - "s3://$TEXTRACT_BUCKET/$TEXT_KEY" --content-type "text/plain"
    Write-Host "[OK] Test text file created" -ForegroundColor Green
}

# Step 2: Send SQS message
Write-Host ""
Write-Host "Step 2: Sending test message to SQS..." -ForegroundColor Yellow
$messageBody = @{
    contract_id = $CONTRACT_ID
    s3_key = "contracts/test/$CONTRACT_ID"
    bucket = "contract-ai-uploads-dev-024441264322"
} | ConvertTo-Json -Compress

[System.IO.File]::WriteAllText("$PWD\test-message.json", $messageBody, [System.Text.UTF8Encoding]::new($false))
aws sqs send-message --queue-url $QUEUE_URL --message-body file://test-message.json
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Message sent to SQS" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Failed to send message" -ForegroundColor Red
    exit 1
}

# Step 3: Show log monitoring commands
Write-Host ""
Write-Host "=== Log Monitoring Commands ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Monitor Bedrock Analyzer logs (main function):" -ForegroundColor Yellow
Write-Host "   aws logs tail /aws/lambda/contract-ai-bedrock-analyzer-dev --follow --format short" -ForegroundColor White
Write-Host ""
Write-Host "2. Get recent Bedrock Analyzer logs (last 5 minutes):" -ForegroundColor Yellow
Write-Host "   aws logs tail /aws/lambda/contract-ai-bedrock-analyzer-dev --since 5m --format short" -ForegroundColor White
Write-Host ""
Write-Host "3. Check DynamoDB for results:" -ForegroundColor Yellow
Write-Host "   aws dynamodb get-item --table-name contract-ai-contracts-dev --key '{\"contract_id\":{\"S\":\"$CONTRACT_ID\"}}'" -ForegroundColor White
Write-Host ""

# Step 4: Wait and check logs
Write-Host "Waiting 5 seconds for Lambda to process..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "Fetching recent Bedrock Analyzer logs..." -ForegroundColor Yellow
aws logs tail /aws/lambda/contract-ai-bedrock-analyzer-dev --since 2m --format short

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan

