# Lambda Deployment Guide

## ⚠️ Important: Use PowerShell 7

The script requires **PowerShell 7** (pwsh), not Windows PowerShell 5.

### Check Your PowerShell Version

```bash
$PSVersionTable.PSVersion
```

If it shows version 5.x, you need PowerShell 7.

### Install PowerShell 7

Download from: https://aka.ms/pscore6

Or use winget:
```bash
winget install Microsoft.PowerShell
```

## 🚀 How to Deploy

### Step 1: Open PowerShell 7

```bash
pwsh
```

### Step 2: Navigate to Backend Directory

```bash
cd C:\Users\tk137\Desktop\aws\backend
```

### Step 3: Run Deployment Script

```bash
.\deploy-simple.ps1
```

## ✅ What the Script Does

1. Loops through all 5 Lambda functions
2. Creates a zip file for each
3. Uploads to AWS Lambda
4. Cleans up zip files
5. Shows success/failure for each

## 📝 Expected Output

```
========================================
Deploying Lambda Functions
========================================

Deploying upload-handler...
  Uploading...
  ✓ upload-handler deployed successfully!

Deploying textract-processor...
  Uploading...
  ✓ textract-processor deployed successfully!

...
```

## 🔧 Troubleshooting

### If you get "command not found"
- Make sure you're using `pwsh` not `powershell`
- Check AWS CLI is installed: `aws --version`

### If deployment fails
- Check function name matches: `contract-ai-{name}-dev`
- Verify AWS credentials: `aws sts get-caller-identity`
- Check region is `us-east-1`

## 🎯 Next Steps After Deployment

1. Test by uploading a file to S3
2. Check CloudWatch logs
3. Verify DynamoDB records

