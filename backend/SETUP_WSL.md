# Setup WSL for Docker Build

## Step 1: Enable Docker Desktop WSL Integration

1. Open **Docker Desktop**
2. Go to **Settings** (gear icon)
3. Click **Resources** â†’ **WSL Integration**
4. Enable integration for **Ubuntu**
5. Click **Apply & Restart**

## Step 2: Install AWS CLI in WSL

Open Ubuntu terminal and run:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt update
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install
```

## Step 3: Configure AWS CLI

```bash
aws configure
```

Enter your AWS credentials (same as Windows).

## Step 4: Verify

```bash
docker --version
aws --version
```

Both should work now.

## Step 5: Build the Container

```bash
cd /mnt/c/Users/tk137/Desktop/aws/backend/models

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Delete old image
aws ecr batch-delete-image --repository-name risk-scorer --image-ids imageTag=latest 2>/dev/null || true

# Build (Docker v2 format)
DOCKER_BUILDKIT=0 docker build --platform linux/amd64 -f Dockerfile.sagemaker -t risk-scorer:latest .

# Tag
docker tag risk-scorer:latest YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/risk-scorer:latest

# Push
docker push YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/risk-scorer:latest

# Verify manifest type
aws ecr batch-get-image --repository-name risk-scorer --image-ids imageTag=latest --query 'images[].imageManifestMediaType' --output text
```

You should see: `application/vnd.docker.distribution.manifest.v2+json`

