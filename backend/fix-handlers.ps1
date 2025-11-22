# Fix Lambda Handler Configuration
# Updates all Lambda functions to use lambda_function.lambda_handler

$functions = @(
    "upload-handler",
    "textract-processor",
    "bedrock-analyzer",
    "sagemaker-scorer",
    "notify-user"
)

$projectName = "contract-ai"
$environment = "dev"

Write-Host "Updating Lambda handlers..." -ForegroundColor Cyan
Write-Host ""

foreach ($name in $functions) {
    $functionName = "$projectName-$name-$environment"
    Write-Host "Updating $functionName..." -ForegroundColor Yellow
    
    aws lambda update-function-configuration --function-name $functionName --handler lambda_function.lambda_handler
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Updated!" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Failed" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "All handlers updated!" -ForegroundColor Cyan

