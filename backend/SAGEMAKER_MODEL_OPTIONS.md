# SageMaker Model Deployment - Options

## Current Status

âœ… **System is fully functional** with fallback risk scoring  
âŒ **SageMaker model deployment blocked** - ECR converts Docker manifests to OCI format, which SageMaker doesn't accept

## Why This Happens

- ECR automatically converts Docker v2 manifests to OCI format when you push
- SageMaker only accepts: `application/vnd.docker.distribution.manifest.v2+json`
- ECR creates: `application/vnd.oci.image.manifest.v1+json` âŒ

## Solutions

### Option 1: Use AWS CodeBuild (Recommended)

CodeBuild runs on Linux and may preserve Docker format better:

1. Create a CodeBuild project:
   - Source: GitHub or S3
   - Environment: Managed image, Linux, Standard 5.0
   - Buildspec: Use the build commands from `build-in-wsl.sh`

2. Or use the AWS Console to build directly

### Option 2: Use EC2 Instance

1. Launch an EC2 instance (Amazon Linux 2)
2. Install Docker and AWS CLI
3. Build and push from EC2
4. ECR might preserve format better from EC2

### Option 3: Use SageMaker Built-in Containers

Instead of custom container, use SageMaker's built-in scikit-learn container:

```bash
aws sagemaker create-model \
  --model-name contract-risk-scorer-dev \
  --execution-role-arn arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/contract-ai-sagemaker-role-dev \
  --primary-container "Image=763104351884.dkr.ecr.us-east-1.amazonaws.com/sklearn-inference:1.0-1-cpu-py3,ModelDataUrl=s3://contract-ai-models-dev-YOUR_AWS_ACCOUNT_ID/risk-scorer/model.pkl"
```

**Note:** You'll need to accept ECR repository terms first (via console).

### Option 4: Keep Using Fallback Scoring

The system works perfectly with fallback scoring. The SageMaker model is optional for production.

## Recommendation

**For now:** Keep using fallback scoring (it's working!)  
**For production:** Use Option 3 (SageMaker built-in container) or Option 1 (CodeBuild)

