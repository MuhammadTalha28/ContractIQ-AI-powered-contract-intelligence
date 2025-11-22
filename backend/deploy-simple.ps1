# Simple Lambda Deployment Script
# Deploys all Lambda functions to AWS

$functions = @(
    @{Dir="uploadHandler"; Name="upload-handler"},
    @{Dir="textractProcessor"; Name="textract-processor"},
    @{Dir="bedrockAnalyzer"; Name="bedrock-analyzer"},
    @{Dir="sageMakerScorer"; Name="sagemaker-scorer"},
    @{Dir="notifyUser"; Name="notify-user"}
)

$basePath = "C:\Users\tk137\Desktop\aws\backend\lambdas"
$projectName = "contract-ai"
$environment = "dev"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deploying Lambda Functions" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($func in $functions) {
    $dirName = $func.Dir
    $funcName = $func.Name
    Write-Host "Deploying $funcName..." -ForegroundColor Yellow
    
    $functionPath = Join-Path $basePath $dirName
    $zipPath = Join-Path $functionPath "function.zip"
    $functionName = "$projectName-$funcName-$environment"
    
    if (-not (Test-Path $functionPath)) {
        Write-Host "  ERROR: Directory not found: $functionPath" -ForegroundColor Red
        continue
    }
    
    Set-Location $functionPath
    
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }
    
    Compress-Archive -Path "lambda_function.py" -DestinationPath "function.zip" -Force
    
    Write-Host "  Uploading..." -ForegroundColor Gray
    $result = aws lambda update-function-code --function-name $functionName --zip-file "fileb://function.zip" --region us-east-1 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Success: $funcName deployed!" -ForegroundColor Green
    } else {
        Write-Host "  Failed: $funcName" -ForegroundColor Red
        Write-Host "  $result" -ForegroundColor Red
    }
    
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

