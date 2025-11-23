# Test pipeline with actual PDF
Write-Host "=== Testing with contract.pdf ===" -ForegroundColor Cyan
Write-Host ""

$BUCKET = "contract-ai-uploads-dev-YOUR_AWS_ACCOUNT_ID"
$PDF_FILE = "contract.pdf"
$S3_KEY = "contracts/test/contract.pdf"

# Step 1: Upload PDF to S3
Write-Host "Step 1: Uploading contract.pdf to S3..." -ForegroundColor Yellow
aws s3 cp $PDF_FILE "s3://$BUCKET/$S3_KEY"

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] PDF uploaded" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Upload failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 2: Waiting for pipeline to process (30 seconds)..." -ForegroundColor Yellow
Write-Host "The pipeline will:" -ForegroundColor White
Write-Host "  1. Extract text from PDF" -ForegroundColor White
Write-Host "  2. Send to Bedrock for analysis" -ForegroundColor White
Write-Host "  3. Save results to DynamoDB" -ForegroundColor White
Write-Host ""

Start-Sleep -Seconds 30

# Step 3: Check logs
Write-Host "Step 3: Checking Bedrock Analyzer logs..." -ForegroundColor Yellow
aws logs tail /aws/lambda/contract-ai-bedrock-analyzer-dev --since 1m --format short

Write-Host ""
Write-Host "Step 4: Checking DynamoDB results..." -ForegroundColor Yellow
aws dynamodb get-item --table-name contract-ai-contracts-dev --key '{\"contract_id\":{\"S\":\"contract.pdf\"}}' --output json

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
Write-Host "To see clauses, run:" -ForegroundColor Yellow
Write-Host "  aws dynamodb scan --table-name contract-ai-clauses-dev --filter-expression 'contract_id = :id' --expression-attribute-values '{\":id\":{\"S\":\"contract.pdf\"}}'" -ForegroundColor White

