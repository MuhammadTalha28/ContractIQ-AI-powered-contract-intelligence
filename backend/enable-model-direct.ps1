# Enable Bedrock model account-wide using your user credentials
# This must be done once with user credentials that have Marketplace permissions

Write-Host "=== Enabling Bedrock Model Account-Wide ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will invoke Claude 3 Sonnet with YOUR user credentials" -ForegroundColor Yellow
Write-Host "to enable it account-wide. After this, Lambda can use it." -ForegroundColor Yellow
Write-Host ""

$modelId = "anthropic.claude-3-sonnet-20240229-v1:0"

# Create JSON body
$bodyJson = @{
    anthropic_version = "bedrock-2023-05-31"
    max_tokens = 100
    messages = @(
        @{
            role = "user"
            content = "Hello, enabling model for account."
        }
    )
} | ConvertTo-Json -Compress

# Save to file without BOM
[System.IO.File]::WriteAllText("$PWD\enable-body.json", $bodyJson, [System.Text.UTF8Encoding]::new($false))

Write-Host "Invoking model with your user credentials..." -ForegroundColor Yellow
Write-Host ""

# Try invoking - this should enable it account-wide
$result = aws bedrock-runtime invoke-model --model-id $modelId --body file://enable-body.json --region us-east-1 enable-response.json 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCCESS] Model enabled account-wide!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Cyan
    if (Test-Path "enable-response.json") {
        Get-Content enable-response.json | ConvertFrom-Json | ConvertTo-Json -Depth 5
    }
    Write-Host ""
    Write-Host "Now test the Lambda pipeline:" -ForegroundColor Yellow
    Write-Host "  .\test-pipeline.ps1" -ForegroundColor White
} else {
    Write-Host "[ERROR] Failed to invoke model" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error output:" -ForegroundColor Yellow
    Write-Host $result
    Write-Host ""
    Write-Host "Possible issues:" -ForegroundColor Yellow
    Write-Host "  1. Your AWS CLI user may not have Marketplace permissions" -ForegroundColor White
    Write-Host "  2. Use case details may not be fully processed yet" -ForegroundColor White
    Write-Host "  3. Check Bedrock console for model access status" -ForegroundColor White
}

# Cleanup
Remove-Item enable-body.json -ErrorAction SilentlyContinue
Remove-Item enable-response.json -ErrorAction SilentlyContinue

