# Building SageMaker Container - Options

The issue: Docker Desktop on Windows converts images to OCI format, which SageMaker doesn't support.

## ✅ Option 1: Use WSL (Recommended)

If you have WSL installed:

1. Open WSL terminal
2. Navigate to project:
   ```bash
   cd /mnt/c/Users/tk137/Desktop/aws/backend
   ```
3. Run the build script:
   ```bash
   chmod +x build-in-wsl.sh
   ./build-in-wsl.sh
   ```

This will build a proper Docker v2 schema 2 image that SageMaker accepts.

---

## ✅ Option 2: Use GitHub Actions

1. Add AWS credentials to GitHub Secrets:
   - Go to your GitHub repo → Settings → Secrets and variables → Actions
   - Add:
     - `AWS_ACCESS_KEY_ID`
     - `AWS_SECRET_ACCESS_KEY`

2. Push the workflow file (already created at `.github/workflows/build-sagemaker-image.yml`)

3. Go to Actions tab → Run workflow manually

This builds on Linux and pushes the correct format.

---

## ✅ Option 3: Use AWS CodeBuild

Create a CodeBuild project that:
- Uses Linux build environment
- Builds the Docker image
- Pushes to ECR

---

## ✅ Option 4: Use EC2 Linux Instance

1. Launch an EC2 Linux instance
2. Install Docker and AWS CLI
3. Build and push from there

---

## Current Status

- ❌ Windows Docker Desktop → OCI format (not supported)
- ✅ Linux/WSL → Docker v2 schema 2 (supported)

Choose the option that works best for you!

