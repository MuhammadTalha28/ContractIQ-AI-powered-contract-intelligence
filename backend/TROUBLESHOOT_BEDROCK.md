# Troubleshooting Bedrock Access Issue

## Current Status
- âœ… Use case submitted 26 hours ago
- âœ… Lambda role has Marketplace permissions
- âœ… Model is available in Bedrock
- âŒ Still getting AccessDeniedException

## The Problem
The error message says: "Your AWS Marketplace subscription for this model cannot be completed at this time."

This suggests the **Marketplace subscription** itself needs activation, even though the use case was approved.

## Steps to Fix

### 1. Check Bedrock Console - Model Access
Go to: https://us-east-1.console.aws.amazon.com/bedrock/home?region=us-east-1#/modelaccess

- Look for "Claude 3 Sonnet" 
- Check if it shows "Access granted" or "Pending"
- If pending, there might be additional steps needed

### 2. Check for Subscription Terms Acceptance
Sometimes Marketplace subscriptions require accepting terms:

1. Go to AWS Marketplace: https://console.aws.amazon.com/marketplace
2. Search for "Claude" or "Anthropic"
3. Look for any pending subscriptions or terms to accept
4. Check if there's a "Subscribe" or "Accept terms" button

### 3. Try Invoking with Your User Credentials
Your AWS CLI user might have different permissions. Try this:

```powershell
# Create a simple test
$body = '{"anthropic_version":"bedrock-2023-05-31","max_tokens":100,"messages":[{"role":"user","content":"test"}]}'
$body | Out-File -FilePath test-body.json -Encoding utf8 -NoNewline

# Try invoking (this might enable it account-wide)
aws bedrock-runtime invoke-model --model-id anthropic.claude-3-sonnet-20240229-v1:0 --body file://test-body.json --region us-east-1 test-response.json
```

### 4. Contact AWS Support
If none of the above works, contact AWS Support:
- Go to: https://console.aws.amazon.com/support
- Create a support case
- Mention: "Bedrock Claude 3 Sonnet Marketplace subscription not activating after use case approval"

### 5. Alternative: Use a Different Model
If you need to test the pipeline immediately, you could temporarily use:
- **Claude 3 Haiku** (if available) - faster, cheaper
- **Amazon Titan** - AWS native, no Marketplace needed
- **Llama 3** (if you have access)

To switch models, update the Lambda environment variable:
```powershell
aws lambda update-function-configuration --function-name contract-ai-bedrock-analyzer-dev --environment Variables="{BEDROCK_MODEL_ID=amazon.titan-text-express-v1,TEXTRACT_BUCKET_NAME=contract-ai-textract-dev-YOUR_AWS_ACCOUNT_ID,CONTRACTS_TABLE=contract-ai-contracts-dev,CLAUSES_TABLE=contract-ai-clauses-dev}"
```

## What's Working
- âœ… All pipeline code is correct
- âœ… All permissions are set up
- âœ… Infrastructure is deployed
- âœ… Lambda functions are working

The **only** blocker is the Marketplace subscription activation.

