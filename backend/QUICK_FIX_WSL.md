# Quick Fix: Install Ubuntu WSL and Build

## Step 1: Install Ubuntu in WSL

Run in PowerShell (as Administrator):

```powershell
wsl --install -d Ubuntu
```

After installation, restart your computer if prompted.

## Step 2: Open Ubuntu and Build

1. Open Ubuntu from Start Menu
2. Run:
   ```bash
   cd /mnt/c/Users/tk137/Desktop/aws/backend
   chmod +x build-in-wsl.sh
   ./build-in-wsl.sh
   ```

This will build the Docker image with the correct format that SageMaker accepts.

---

## Alternative: Use GitHub Actions

If you prefer not to install WSL:

1. Push your code to GitHub
2. Add AWS credentials to GitHub Secrets:
   - Go to: Settings → Secrets and variables → Actions
   - Add: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
3. Go to Actions tab → Run the "Build and Push SageMaker Container" workflow

---

## Why This is Needed

- Windows Docker Desktop → Creates OCI format ❌
- Linux/WSL → Creates Docker v2 schema 2 ✅
- SageMaker only accepts Docker v2 schema 2

