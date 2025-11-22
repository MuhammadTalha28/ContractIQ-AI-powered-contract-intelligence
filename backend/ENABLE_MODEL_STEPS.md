# Enable Claude 3 Sonnet Account-Wide

## The Problem
The Lambda has Marketplace permissions, but the model needs to be enabled account-wide first by invoking it with user credentials that have Marketplace permissions.

## Solution: Use Bedrock Console Playground

This is the **easiest way** to enable the model:

### Steps:

1. **Go to Bedrock Console**:
   - https://us-east-1.console.aws.amazon.com/bedrock/home?region=us-east-1
   - Make sure you're in **us-east-1** region

2. **Open Model Catalog**:
   - Click "Model catalog" in the left sidebar
   - Or go to: https://us-east-1.console.aws.amazon.com/bedrock/home?region=us-east-1#/modelaccess

3. **Find Claude 3 Sonnet**:
   - Search for "Claude 3 Sonnet"
   - Click on the model card

4. **Open in Playground**:
   - Click "Open in Playground" or "Try model" button
   - This will open the Bedrock playground

5. **Invoke the Model**:
   - Type any simple message like: "Hello"
   - Click "Run" or "Invoke"
   - This **one invocation** will enable the model account-wide

6. **Verify It Works**:
   - You should see a response from Claude
   - This means the model is now enabled

7. **Test Your Pipeline**:
   ```powershell
   cd backend
   .\test-pipeline.ps1
   ```

## Why This Works

According to AWS documentation:
- "When you first invoke an Amazon Bedrock serverless model served from AWS Marketplace in an account, Bedrock attempts to automatically enable the model for your account"
- "Once enabled, all users in the account can invoke the model without needing AWS Marketplace permissions"

By invoking it in the playground with your user account (which has Marketplace permissions), you enable it for the entire account, including your Lambda functions.

## Alternative: Install boto3 and Run Script

If you prefer to use the command line:

```powershell
# Install boto3
pip install boto3

# Run the enable script
python enable_model.py
```

But the **console playground method is easier and more reliable**.

