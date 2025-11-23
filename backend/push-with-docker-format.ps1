# Push Docker image with Docker v2 format (after disabling containerd)
Write-Host "=== Pushing Image with Docker v2 Format ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "IMPORTANT: Make sure you've disabled containerd in Docker Desktop:" -ForegroundColor Yellow
Write-Host "  Settings â†’ Features in development â†’ Disable containerd options" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Have you disabled containerd and restarted Docker? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Please disable containerd first, then run this script again." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 1: Deleting old image from ECR..." -ForegroundColor Yellow
wsl -d Ubuntu bash -c "aws ecr batch-delete-image --repository-name risk-scorer --image-ids imageTag=latest 2>/dev/null || true"

Write-Host ""
Write-Host "Step 2: Logging into ECR..." -ForegroundColor Yellow
wsl -d Ubuntu bash -c "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com"

Write-Host ""
Write-Host "Step 3: Tagging image..." -ForegroundColor Yellow
wsl -d Ubuntu bash -c "docker tag risk-scorer:latest YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/risk-scorer:latest"

Write-Host ""
Write-Host "Step 4: Pushing to ECR..." -ForegroundColor Yellow
wsl -d Ubuntu bash -c "docker push YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/risk-scorer:latest 2>&1 | tail -5"

Write-Host ""
Write-Host "Step 5: Verifying manifest type..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
$manifestType = wsl -d Ubuntu bash -c "aws ecr batch-get-image --repository-name risk-scorer --image-ids imageTag=latest --query 'images[].imageManifestMediaType' --output text"

Write-Host ""
Write-Host "Manifest type: $manifestType" -ForegroundColor White

if ($manifestType -eq "application/vnd.docker.distribution.manifest.v2+json") {
    Write-Host "[SUCCESS] Docker v2 schema 2 - SageMaker compatible!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Step 6: Creating SageMaker model..." -ForegroundColor Yellow
    .\create-sagemaker-model-with-custom-image.ps1
} else {
    Write-Host "[ERROR] Still wrong format: $manifestType" -ForegroundColor Red
    Write-Host "Expected: application/vnd.docker.distribution.manifest.v2+json" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Try:" -ForegroundColor Yellow
    Write-Host "1. Make sure containerd is disabled in Docker Desktop" -ForegroundColor White
    Write-Host "2. Restart Docker Desktop completely" -ForegroundColor White
    Write-Host "3. Rebuild the image: DOCKER_BUILDKIT=0 docker build ..." -ForegroundColor White
}

