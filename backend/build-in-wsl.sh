#!/bin/bash
# Build script for WSL/Linux to create Docker v2 schema 2 image

set -e

echo "=== Building SageMaker Container (Linux/WSL) ==="
echo ""

# Configuration
ECR_URI="YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com"
REPO_NAME="risk-scorer"
IMAGE_TAG="latest"
FULL_IMAGE="$ECR_URI/$REPO_NAME:$IMAGE_TAG"

# Navigate to models directory
cd "$(dirname "$0")/models" || exit 1

echo "Step 1: Logging into ECR..."
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URI

echo ""
echo "Step 2: Deleting old image from ECR..."
aws ecr batch-delete-image --repository-name $REPO_NAME --image-ids imageTag=$IMAGE_TAG 2>/dev/null || true

echo ""
echo "Step 3: Building Docker image (linux/amd64, Docker v2 format)..."
DOCKER_BUILDKIT=0 docker build \
    --platform linux/amd64 \
    -f Dockerfile.sagemaker \
    -t $REPO_NAME:$IMAGE_TAG \
    .

echo ""
echo "Step 4: Tagging for ECR..."
docker tag $REPO_NAME:$IMAGE_TAG $FULL_IMAGE

echo ""
echo "Step 5: Pushing to ECR..."
docker push $FULL_IMAGE

echo ""
echo "Step 6: Verifying manifest type..."
sleep 3
MANIFEST_TYPE=$(aws ecr batch-get-image \
    --repository-name $REPO_NAME \
    --image-ids imageTag=$IMAGE_TAG \
    --query 'images[].imageManifestMediaType' \
    --output text)

echo "Manifest type: $MANIFEST_TYPE"

if [ "$MANIFEST_TYPE" = "application/vnd.docker.distribution.manifest.v2+json" ]; then
    echo "[SUCCESS] Docker v2 schema 2 - SageMaker compatible!"
    echo ""
    echo "Step 7: Creating SageMaker model..."
    cd ..
    python3 create-sagemaker-model-with-custom-image.py || echo "Run create-sagemaker-model-with-custom-image.ps1 manually"
else
    echo "[ERROR] Still wrong format: $MANIFEST_TYPE"
    echo "Expected: application/vnd.docker.distribution.manifest.v2+json"
    exit 1
fi

