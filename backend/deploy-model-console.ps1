# Instructions for deploying SageMaker model via Console
Write-Host "=== SageMaker Model Deployment ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "The model is trained and uploaded to S3:" -ForegroundColor Yellow
Write-Host "  s3://contract-ai-models-dev-YOUR_AWS_ACCOUNT_ID/risk-scorer/model.pkl" -ForegroundColor White
Write-Host ""
Write-Host "To deploy via AWS Console:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Go to: https://console.aws.amazon.com/sagemaker/home?region=us-east-1#/models" -ForegroundColor Cyan
Write-Host "2. Click 'Create model'" -ForegroundColor White
Write-Host "3. Model name: contract-risk-scorer-dev" -ForegroundColor White
Write-Host "4. IAM role: contract-ai-sagemaker-role-dev" -ForegroundColor White
Write-Host "5. Container: Use an existing container" -ForegroundColor White
Write-Host "   Image: 763104351884.dkr.ecr.us-east-1.amazonaws.com/sklearn-inference:1.0-1-cpu-py3" -ForegroundColor White
Write-Host "   Model data: s3://contract-ai-models-dev-YOUR_AWS_ACCOUNT_ID/risk-scorer/model.pkl" -ForegroundColor White
Write-Host "6. Click 'Create model'" -ForegroundColor White
Write-Host ""
Write-Host "7. Go to: https://console.aws.amazon.com/sagemaker/home?region=us-east-1#/endpoints" -ForegroundColor Cyan
Write-Host "8. Click 'Create endpoint'" -ForegroundColor White
Write-Host "9. Endpoint name: contract-risk-scorer-dev" -ForegroundColor White
Write-Host "10. Endpoint config: Create new" -ForegroundColor White
Write-Host "    Model: contract-risk-scorer-dev" -ForegroundColor White
Write-Host "    Instance: ml.t2.medium" -ForegroundColor White
Write-Host "    Count: 1" -ForegroundColor White
Write-Host "11. Click 'Create endpoint' (takes 5-10 minutes)" -ForegroundColor White
Write-Host ""
Write-Host "Once endpoint is 'InService', the Lambda will automatically use it!" -ForegroundColor Green
Write-Host ""

