# Quick SageMaker Model Deployment

## âš¡ Fast Track (5 minutes)

The model is **ready** - just needs to be deployed via AWS Console (ECR permissions require console acceptance).

### Step 1: Create Model (2 minutes)

1. **Open:** https://console.aws.amazon.com/sagemaker/home?region=us-east-1#/models
2. Click **"Create model"**
3. Fill in:
   - **Model name:** `contract-risk-scorer-dev`
   - **IAM role:** `contract-ai-sagemaker-role-dev`
   - **Container definition:** Select **"Use an existing container"**
   - **Image:** `763104351884.dkr.ecr.us-east-1.amazonaws.com/sklearn-inference:1.0-1-cpu-py3`
   - **Model data source:** Select **"S3"**
   - **S3 location:** `s3://contract-ai-models-dev-YOUR_AWS_ACCOUNT_ID/risk-scorer/model.pkl`
4. Click **"Create model"**

### Step 2: Create Endpoint (3 minutes setup, 5-10 minutes deployment)

1. **Open:** https://console.aws.amazon.com/sagemaker/home?region=us-east-1#/endpoints
2. Click **"Create endpoint"**
3. Fill in:
   - **Endpoint name:** `contract-risk-scorer-dev`
   - **Endpoint configuration:** Click **"Create new"**
     - **Name:** `contract-risk-scorer-dev-config`
     - **Model:** Select `contract-risk-scorer-dev`
     - **Variant name:** `AllTraffic`
     - **Instance type:** `ml.t2.medium`
     - **Initial instance count:** `1`
   - Click **"Create endpoint configuration"**
4. Click **"Create endpoint"**

### Step 3: Monitor & Test

Once you've started deployment, run:
```powershell
.\monitor-and-test-model.ps1
```

This will:
- Monitor endpoint status
- Automatically test when ready
- Show results

**OR** test manually:
```powershell
.\test-sagemaker-endpoint.ps1
```

---

## âœ… What's Already Done

- âœ… Model trained (`model.pkl`)
- âœ… Model uploaded to S3
- âœ… SageMaker role created with permissions
- âœ… Lambda configured to use endpoint
- âœ… Lambda has invoke permissions

## ðŸŽ¯ After Deployment

The system will **automatically** use the ML model instead of fallback scoring!

Test the full pipeline:
```powershell
.\test-with-pdf.ps1
```

