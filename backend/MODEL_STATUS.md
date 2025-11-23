# SageMaker Model Status

## âœ… Completed
- âœ… Model trained (`model.pkl` created)
- âœ… Model uploaded to S3: `s3://contract-ai-models-dev-YOUR_AWS_ACCOUNT_ID/risk-scorer/model.pkl`
- âœ… SageMaker execution role created: `contract-ai-sagemaker-role-dev`
- âœ… Lambda scorer configured to use endpoint: `contract-risk-scorer-dev`
- âœ… Lambda has SageMaker invoke permissions

## â³ Pending
- â³ **Deploy model via AWS Console** (ECR permissions require console acceptance)
  - See `deploy-model-console.ps1` for step-by-step instructions
  - Or run: `.\deploy-model-console.ps1` to see instructions

## Current Behavior
- The system **currently uses fallback scoring** (no SageMaker needed)
- Once the endpoint is deployed and "InService", the Lambda will automatically switch to using the ML model
- Fallback scoring still provides reasonable risk scores based on contract features

## After Deployment
1. Check endpoint status:
   ```powershell
   aws sagemaker describe-endpoint --endpoint-name contract-risk-scorer-dev
   ```
2. When status is "InService", test with:
   ```powershell
   .\test-with-pdf.ps1
   ```
3. Check CloudWatch logs to see if ML model is being used:
   ```powershell
   aws logs tail /aws/lambda/contract-ai-sage-maker-scorer-dev --follow
   ```

