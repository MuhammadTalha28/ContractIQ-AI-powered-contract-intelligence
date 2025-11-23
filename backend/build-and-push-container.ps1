# Build and Push Custom SageMaker Container to ECR
Write-Host "=== Building Custom SageMaker Container ===" -ForegroundColor Cyan
Write-Host ""

# Check Docker
Write-Host "Step 1: Checking Docker..." -ForegroundColor Yellow
try {
    docker --version | Out-Null
    Write-Host "   [OK] Docker is available" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] Docker not found. Please install Docker Desktop." -ForegroundColor Red
    exit 1
}

# Check if Docker is running
try {
    docker ps | Out-Null
    Write-Host "   [OK] Docker is running" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] Docker Desktop is not running. Please start Docker Desktop first." -ForegroundColor Red
    Write-Host "   Then run this script again." -ForegroundColor Yellow
    exit 1
}

# Navigate to models directory
$modelsDir = Join-Path $PSScriptRoot "models"
if (-not (Test-Path $modelsDir)) {
    Write-Host "   [ERROR] models directory not found" -ForegroundColor Red
    exit 1
}

Set-Location $modelsDir

# Check required files
Write-Host "`nStep 2: Checking required files..." -ForegroundColor Yellow
if (-not (Test-Path "model.pkl")) {
    Write-Host "   Training model..." -ForegroundColor Yellow
    python -c "from risk_scorer_model import train_model; train_model()"
    if (-not (Test-Path "model.pkl")) {
        Write-Host "   [ERROR] Failed to create model.pkl" -ForegroundColor Red
        exit 1
    }
}
Write-Host "   [OK] model.pkl found" -ForegroundColor Green

if (-not (Test-Path "inference.py")) {
    Write-Host "   [ERROR] inference.py not found" -ForegroundColor Red
    exit 1
}
Write-Host "   [OK] inference.py found" -ForegroundColor Green

if (-not (Test-Path "Dockerfile.sagemaker")) {
    Write-Host "   [ERROR] Dockerfile.sagemaker not found" -ForegroundColor Red
    exit 1
}
Write-Host "   [OK] Dockerfile.sagemaker found" -ForegroundColor Green

# ECR configuration
$ECR_URI = "YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com"
$IMAGE_NAME = "risk-scorer"
$IMAGE_TAG = "latest"
$FULL_IMAGE = "$ECR_URI/$IMAGE_NAME`:$IMAGE_TAG"

# Login to ECR
Write-Host "`nStep 3: Logging in to ECR..." -ForegroundColor Yellow
$loginPassword = aws ecr get-login-password --region us-east-1 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "   [ERROR] Failed to get ECR login password" -ForegroundColor Red
    exit 1
}

$loginPassword | docker login --username AWS --password-stdin $ECR_URI 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Logged in to ECR" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] Failed to login to ECR" -ForegroundColor Red
    exit 1
}

# Build Docker image (Linux/amd64 platform for SageMaker)
Write-Host "`nStep 4: Building Docker image..." -ForegroundColor Yellow
Write-Host "   This may take a few minutes..." -ForegroundColor Gray
docker build --platform linux/amd64 -f Dockerfile.sagemaker -t "$IMAGE_NAME`:$IMAGE_TAG" . 2>&1 | ForEach-Object {
    if ($_ -match "ERROR") {
        Write-Host "   $_" -ForegroundColor Red
    } elseif ($_ -match "Step \d+/\d+") {
        Write-Host "   $_" -ForegroundColor Gray
    }
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "   [ERROR] Docker build failed" -ForegroundColor Red
    exit 1
}
Write-Host "   [OK] Image built successfully" -ForegroundColor Green

# Tag image
Write-Host "`nStep 5: Tagging image for ECR..." -ForegroundColor Yellow
docker tag "$IMAGE_NAME`:$IMAGE_TAG" $FULL_IMAGE
if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Image tagged: $FULL_IMAGE" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] Failed to tag image" -ForegroundColor Red
    exit 1
}

# Push to ECR (disable multi-platform manifest)
Write-Host "`nStep 6: Pushing to ECR..." -ForegroundColor Yellow
Write-Host "   This may take a few minutes..." -ForegroundColor Gray
$env:DOCKER_CLI_EXPERIMENTAL = "enabled"
docker push --platform linux/amd64 $FULL_IMAGE 2>&1 | ForEach-Object {
    if ($_ -match "error|ERROR") {
        Write-Host "   $_" -ForegroundColor Red
    } elseif ($_ -match "Pushing|Pushed|Layer") {
        Write-Host "   $_" -ForegroundColor Gray
    }
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Image pushed successfully" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] Failed to push image" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Container Build Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Image URI: $FULL_IMAGE" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next step: Create SageMaker model using this image:" -ForegroundColor Yellow
Write-Host "  Image: $FULL_IMAGE" -ForegroundColor White
Write-Host "  Model data: s3://contract-ai-models-dev-YOUR_AWS_ACCOUNT_ID/risk-scorer/model.pkl" -ForegroundColor White
Write-Host ""
Write-Host "Run: .\create-sagemaker-model-with-custom-image.ps1" -ForegroundColor Cyan

Set-Location $PSScriptRoot

