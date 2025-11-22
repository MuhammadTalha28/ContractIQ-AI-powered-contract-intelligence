# PowerShell script to deploy all Lambda functions
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deploying Lambda Functions" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseDir = $PSScriptRoot
$lambdasDir = Join-Path $baseDir "lambdas"
$projectName = "contract-ai"
$environment = "dev"

function Deploy-Lambda {
    param(
        [string]$FunctionName,
        [string]$FunctionDir
    )
    
    Write-Host "Deploying $FunctionName..." -ForegroundColor Yellow
    
    $functionPath = Join-Path $lambdasDir $FunctionDir
    
    if (-not (Test-Path $functionPath)) {
        Write-Host "  ERROR: Directory not found: $functionPath" -ForegroundColor Red
        return $false
    }
    
    $lambdaFile = Join-Path $functionPath "lambda_function.py"
    if (-not (Test-Path $lambdaFile)) {
        Write-Host "  ERROR: lambda_function.py not found" -ForegroundColor Red
        return $false
    }
    
    Push-Location $functionPath
    $tempDir = $null
    $zipFile = $null
    $success = $false
    
    try {
        $tempDir = Join-Path $env:TEMP "lambda-$FunctionName"
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }
        New-Item -ItemType Directory -Path $tempDir | Out-Null
        
        Copy-Item $lambdaFile $tempDir
        
        $requirementsFile = Join-Path $functionPath "requirements.txt"
        if (Test-Path $requirementsFile) {
            Write-Host "  Installing dependencies..." -ForegroundColor Gray
            pip install -r $requirementsFile -t $tempDir --quiet 2>&1 | Out-Null
        }
        
        $zipFile = Join-Path $env:TEMP "$FunctionName.zip"
        if (Test-Path $zipFile) {
            Remove-Item $zipFile -Force
        }
        
        Write-Host "  Creating deployment package..." -ForegroundColor Gray
        Compress-Archive -Path "$tempDir\*" -DestinationPath $zipFile -Force
        
        $awsFunctionName = "$projectName-$FunctionName-$environment"
        
        Write-Host "  Uploading to AWS Lambda..." -ForegroundColor Gray
        $result = aws lambda update-function-code --function-name $awsFunctionName --zip-file "fileb://$zipFile" --region us-east-1 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ $FunctionName deployed successfully!" -ForegroundColor Green
            $success = $true
        }
        else {
            Write-Host "  ERROR: Failed to deploy $FunctionName" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        Pop-Location
        if ($tempDir -and (Test-Path $tempDir)) {
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        if ($zipFile -and (Test-Path $zipFile)) {
            Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
        }
    }
    
    return $success
}

$functions = @(
    @{Name="upload-handler"; Dir="uploadHandler"},
    @{Name="textract-processor"; Dir="textractProcessor"},
    @{Name="bedrock-analyzer"; Dir="bedrockAnalyzer"},
    @{Name="sagemaker-scorer"; Dir="sageMakerScorer"},
    @{Name="notify-user"; Dir="notifyUser"}
)

Write-Host "Found $($functions.Count) functions to deploy" -ForegroundColor Cyan
Write-Host ""

$successCount = 0
$failCount = 0

foreach ($func in $functions) {
    $result = Deploy-Lambda -FunctionName $func.Name -FunctionDir $func.Dir
    if ($result) {
        $successCount++
    }
    else {
        $failCount++
    }
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Success: $successCount" -ForegroundColor Green
if ($failCount -gt 0) {
    Write-Host "Failed:  $failCount" -ForegroundColor Red
}
else {
    Write-Host "Failed:  $failCount" -ForegroundColor Green
}
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "All Lambda functions deployed successfully! ✓" -ForegroundColor Green
}
else {
    Write-Host "Some functions failed to deploy. Check errors above." -ForegroundColor Yellow
}
