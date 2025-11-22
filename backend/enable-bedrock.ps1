# One-time Bedrock model enablement script
# This invokes the model once with your AWS CLI credentials to enable it account-wide

Write-Host "=== Enabling Bedrock Model (One-Time) ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will invoke Claude 3 Sonnet once to enable it account-wide." -ForegroundColor Yellow
Write-Host "After this, the Lambda role can use it without Marketplace permissions." -ForegroundColor Yellow
Write-Host ""

$modelId = "anthropic.claude-3-sonnet-20240229-v1:0"
$testPrompt = @{
    anthropic_version = "bedrock-2023-05-31"
    max_tokens = 100
    messages = @(
        @{
            role = "user"
            content = "Hello, this is a test to enable the model."
        }
    )
} | ConvertTo-Json -Compress

# Save to file
[System.IO.File]::WriteAllText("$PWD\bedrock-enable.json", $testPrompt, [System.Text.UTF8Encoding]::new($false))

Write-Host "Invoking model to enable it..." -ForegroundColor Yellow
aws bedrock-runtime invoke-model --model-id $modelId --body file://bedrock-enable.json --region us-east-1 bedrock-response.json

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[SUCCESS] Model enabled! The Lambda role can now use it." -ForegroundColor Green
    Write-Host ""
    Write-Host "Response preview:" -ForegroundColor Cyan
    Get-Content bedrock-response.json | ConvertFrom-Json | ConvertTo-Json -Depth 10
    Remove-Item bedrock-response.json -ErrorAction SilentlyContinue
} else {
    Write-Host ""
    Write-Host "[ERROR] Failed to enable model. Check the error above." -ForegroundColor Red
    Write-Host "You may need to:" -ForegroundColor Yellow
    Write-Host "  1. Submit use case details in Bedrock console" -ForegroundColor White
    Write-Host "  2. Wait 10-15 minutes for processing" -ForegroundColor White
    Write-Host "  3. Ensure your AWS CLI credentials have Marketplace permissions" -ForegroundColor White
}

Remove-Item bedrock-enable.json -ErrorAction SilentlyContinue

