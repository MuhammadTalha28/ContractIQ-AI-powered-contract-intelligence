# Replace Credentials Before Committing

## Quick Fix Script

Run this PowerShell script to replace AWS Account ID in all deployment scripts:

```powershell
# Replace AWS Account ID with placeholder
$accountId = "YOUR_AWS_ACCOUNT_ID"
$placeholder = "YOUR_AWS_ACCOUNT_ID"

Get-ChildItem -Path . -Include *.ps1,*.sh,*.py -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $newContent = $content -replace $accountId, $placeholder
    if ($content -ne $newContent) {
        Set-Content -Path $_.FullName -Value $newContent -NoNewline
        Write-Host "Updated: $($_.FullName)"
    }
}
```

## Manual Replacement

### Files with AWS Account ID (YOUR_AWS_ACCOUNT_ID):

**PowerShell Scripts:**
- `backend/push-with-docker-format.ps1`
- `backend/build-and-push-container.ps1`
- `backend/create-sagemaker-model-with-custom-image.ps1`
- `backend/monitor-and-test-model.ps1`
- `backend/deploy-model-console.ps1`
- `backend/deploy-and-test-model.ps1`
- `backend/create-sagemaker-model.ps1`
- `backend/deploy-sagemaker-model.ps1`
- `backend/setup-api-gateway.ps1`
- `backend/test-with-pdf.ps1`
- `backend/test-pipeline.ps1`
- `backend/add-sqs-permission.ps1`

**Shell Scripts:**
- `backend/push-docker-v2.sh`
- `backend/build-in-wsl.sh`
- `backend/SETUP_WSL.md`
- `backend/BUILD_NOW.md`

**Python Scripts:**
- `backend/deploy-model-boto3.py`
- `backend/deploy-model-simple.py`

**JSON Files:**
- `backend/sagemaker-invoke-policy.json`
- `backend/sagemaker-role-policy.json`
- `backend/lambda-invoke-policy.json`
- `backend/current-policy.json`
- `backend/sqs-policy.json`

### Replace Pattern:
- Find: `YOUR_AWS_ACCOUNT_ID`
- Replace: `YOUR_AWS_ACCOUNT_ID` or `${AWS_ACCOUNT_ID}`

## Frontend Files

All frontend files now use environment variables. Just create `frontend/.env.local`:

```bash
NEXT_PUBLIC_API_URL=https://YOUR_API_GATEWAY_ID.execute-api.us-east-1.amazonaws.com/dev
```

## After Replacement

1. Test that placeholders work
2. Update documentation to mention placeholders
3. Commit changes
4. Add actual values to your local `.env` files (not committed)

