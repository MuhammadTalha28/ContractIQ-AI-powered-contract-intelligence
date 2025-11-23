# Security & Credentials

## ⚠️ Before Committing to GitHub

This repository contains placeholder values that **MUST** be replaced with your own values before deployment.

## 🔒 Sensitive Information to Replace

### 1. AWS Account ID
**Files to update:**
- All `*.ps1` deployment scripts in `backend/`
- All `*.sh` deployment scripts in `backend/`
- CloudFormation templates in `infrastructure/`
- Python deployment scripts

**Replace:** `024441264322` or `YOUR_AWS_ACCOUNT_ID` with your actual AWS Account ID

### 2. API Gateway URL
**Files to update:**
- `frontend/app/upload/page.tsx`
- `frontend/app/dashboard/page.tsx`
- `frontend/app/login/page.tsx`
- `frontend/app/contracts/[id]/page.tsx`

**Replace:** `YOUR_API_GATEWAY_URL` with your actual API Gateway endpoint

**Or use environment variable:**
```bash
# Create frontend/.env.local
NEXT_PUBLIC_API_URL=https://your-api-id.execute-api.us-east-1.amazonaws.com/dev
```

### 3. AWS Credentials
**Never commit:**
- `~/.aws/credentials`
- `~/.aws/config` (if it contains access keys)
- Any files with `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY`

**Use instead:**
- AWS CLI configured locally
- IAM roles for Lambda/EC2
- Environment variables (not in git)

### 4. S3 Bucket Names
**Files to update:**
- CloudFormation templates
- Lambda environment variables
- Deployment scripts

**Replace:** Bucket names containing account IDs

## ✅ Safe to Commit

- ✅ CloudFormation templates (with placeholders)
- ✅ Lambda function code (uses environment variables)
- ✅ Frontend code (uses environment variables)
- ✅ Documentation files
- ✅ `.env.example` files

## 🛡️ Best Practices

1. **Use Environment Variables**: Never hardcode credentials
2. **Use IAM Roles**: Prefer IAM roles over access keys
3. **Use Secrets Manager**: For production secrets
4. **Review Before Commit**: Check for hardcoded values
5. **Use .gitignore**: Ensure `.env` files are ignored

## 📝 Quick Checklist Before Commit

- [ ] Replaced all AWS Account IDs with placeholders
- [ ] Replaced API Gateway URLs with environment variables
- [ ] Verified `.env` files are in `.gitignore`
- [ ] No hardcoded access keys or secrets
- [ ] All sensitive files excluded from git

## 🔍 Finding Hardcoded Values

Search for:
```bash
# AWS Account ID
grep -r "024441264322" .

# API Gateway URLs
grep -r "execute-api" frontend/

# Access Keys (if any)
grep -r "AKIA" .
```

## 📚 Resources

- [AWS Security Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [GitHub Security](https://docs.github.com/en/code-security)

