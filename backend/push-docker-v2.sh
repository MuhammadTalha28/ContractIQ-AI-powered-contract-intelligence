#!/bin/bash
# Push Docker image with Docker v2 format (after disabling containerd in Docker Desktop)

set -e

ECR_URI="YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com"
REPO_NAME="risk-scorer"
IMAGE_TAG="latest"
FULL_IMAGE="$ECR_URI/$REPO_NAME:$IMAGE_TAG"

echo "=== Pushing with Docker v2 Format ==="
echo ""
echo "IMPORTANT: Make sure containerd is disabled in Docker Desktop!"
echo "  Settings â†’ Features in development â†’ Disable containerd"
echo ""

read -p "Have you disabled containerd and restarted Docker? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please disable containerd first!"
    exit 1
fi

echo ""
echo "Step 1: Deleting old image from ECR..."
aws ecr batch-delete-image --repository-name $REPO_NAME --image-ids imageTag=$IMAGE_TAG 2>/dev/null || true

echo ""
echo "Step 2: Logging into ECR..."
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URI

echo ""
echo "Step 3: Tagging image..."
docker tag $REPO_NAME:$IMAGE_TAG $FULL_IMAGE

echo ""
echo "Step 4: Pushing to ECR..."
docker push $FULL_IMAGE

echo ""
echo "Step 5: Verifying manifest type..."
sleep 3
MANIFEST_TYPE=$(aws ecr batch-get-image \
    --repository-name $REPO_NAME \
    --image-ids imageTag=$IMAGE_TAG \
    --query 'images[].imageManifestMediaType' \
    --output text)

echo ""
echo "Manifest type: $MANIFEST_TYPE"

if [ "$MANIFEST_TYPE" = "application/vnd.docker.distribution.manifest.v2+json" ]; then
    echo "[SUCCESS] Docker v2 schema 2 - SageMaker compatible!"
    echo ""
    echo "Now create the SageMaker model using:"
    echo "  cd /mnt/c/Users/tk137/Desktop/aws/backend"
    echo "  ./create-sagemaker-model-with-custom-image.ps1"
else
    echo "[ERROR] Still wrong format: $MANIFEST_TYPE"
    echo "Expected: application/vnd.docker.distribution.manifest.v2+json"
    echo ""
    echo "Make sure:"
    echo "1. containerd is disabled in Docker Desktop"
    echo "2. Docker Desktop is fully restarted"
    echo "3. Rebuild with: DOCKER_BUILDKIT=0 docker build ..."
fi

