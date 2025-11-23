# Build Docker Image in WSL - Quick Steps

## Step 1: Enable Docker in WSL (if not done)

1. Open **Docker Desktop**
2. Go to **Settings** (gear icon) â†’ **Resources** â†’ **WSL Integration**
3. Enable **Ubuntu**
4. Click **Apply & Restart**

Wait for Docker Desktop to restart.

## Step 2: Fix AWS Config (Optional)

If you want to set the region correctly:

```bash
aws configure set region us-east-1
aws configure set output json
```

## Step 3: Build the Container

Run these commands in your Ubuntu terminal:

```bash
# Navigate to models directory
cd /mnt/c/Users/tk137/Desktop/aws/backend/models

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Delete old image
aws ecr batch-delete-image --repository-name risk-scorer --image-ids imageTag=latest 2>/dev/null || true

# Build (Docker v2 format - this is the key!)
DOCKER_BUILDKIT=0 docker build --platform linux/amd64 -f Dockerfile.sagemaker -t risk-scorer:latest .

# Tag
docker tag risk-scorer:latest YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/risk-scorer:latest

# Push
docker push YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/risk-scorer:latest

# Verify manifest type (should be Docker v2)
aws ecr batch-get-image --repository-name risk-scorer --image-ids imageTag=latest --query 'images[].imageManifestMediaType' --output text
```

**Expected output:** `application/vnd.docker.distribution.manifest.v2+json`

If you see that, the image is ready for SageMaker!

