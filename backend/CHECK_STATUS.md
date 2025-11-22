# Bedrock Model Access Status Check

## Current Situation

✅ **Model is available**: Claude 3 Sonnet is listed and supports ON_DEMAND inference
✅ **Lambda permissions**: Marketplace permissions added
❌ **Model access**: Still getting AccessDeniedException

## What You Need to Do

For **Anthropic models**, AWS requires use case details to be submitted before first use.

### Steps to Enable Claude 3 Sonnet:

1. **Go to Bedrock Console**:
   - Navigate to: https://console.aws.amazon.com/bedrock
   - Region: **us-east-1** (important!)

2. **Open Model Catalog**:
   - Click "Model catalog" in the left sidebar
   - Or go directly to: https://us-east-1.console.aws.amazon.com/bedrock/home?region=us-east-1#/modelaccess

3. **Find Claude 3 Sonnet**:
   - Search for "Claude 3 Sonnet"
   - Click on the model card

4. **Submit Use Case Details**:
   - Look for a button/link like "Request access" or "Submit use case"
   - Fill out the form with:
     - **Use case**: Contract analysis, document review, legal document processing
     - **Description**: AI-powered contract review and risk analysis platform
     - **Company**: Your company/portfolio name
     - **Website**: https://www.muhammadtalhakhalid.com/

5. **Wait for Approval**:
   - Usually takes 10-15 minutes
   - You'll receive an email when approved

6. **Test Again**:
   ```powershell
   cd backend
   .\test-pipeline.ps1
   ```

## Alternative: Try Invoking from Your AWS CLI

Your AWS CLI credentials might have different permissions. Try invoking the model directly:

```powershell
# This might work if your user has Marketplace permissions
aws bedrock-runtime invoke-model --model-id anthropic.claude-3-sonnet-20240229-v1:0 --body file://bedrock-enable.json --region us-east-1 response.json
```

If this works, it will enable the model account-wide, and then the Lambda can use it.

