# Deploy SageMaker Model

## Option 1: Using AWS Console (Recommended)

1. Go to **SageMaker Console** â†’ **Models** â†’ **Create model**
2. Model name: `contract-risk-scorer-dev`
3. IAM role: `contract-ai-sagemaker-role-dev`
4. Container: **Use an existing container**
   - Image: `763104351884.dkr.ecr.us-east-1.amazonaws.com/sklearn-inference:1.0-1-cpu-py3`
   - Model data: `s3://contract-ai-models-dev-YOUR_AWS_ACCOUNT_ID/risk-scorer/model.pkl`
5. Click **Create model**

6. Go to **Endpoints** â†’ **Create endpoint**
   - Endpoint name: `contract-risk-scorer-dev`
   - Endpoint config: Create new
     - Model: `contract-risk-scorer-dev`
     - Instance type: `ml.t2.medium`
     - Initial instance count: `1`
7. Click **Create endpoint** (takes 5-10 minutes)

## Option 2: Using AWS CLI (After accepting ECR terms)

The ECR repository needs to be accepted first. You can do this via:
- AWS Console â†’ ECR â†’ Public repositories â†’ Search "sklearn"
- Or use the SageMaker console which auto-accepts

Then run:
```powershell
.\deploy-sagemaker-model.ps1
```

## Option 3: Use Fallback (Current)

The system currently uses fallback scoring (no SageMaker needed). To use actual ML model:
1. Deploy model using Option 1 or 2
2. Update Lambda environment variable:
   ```powershell
   aws lambda update-function-configuration --function-name contract-ai-sage-maker-scorer-dev --environment Variables="{SAGEMAKER_ENDPOINT_NAME=contract-risk-scorer-dev}"
   ```

## Verify Deployment

Check endpoint status:
```powershell
aws sagemaker describe-endpoint --endpoint-name contract-risk-scorer-dev
```

When status is "InService", the model is ready.

