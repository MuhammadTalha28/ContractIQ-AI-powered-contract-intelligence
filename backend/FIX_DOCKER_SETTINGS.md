# Fix Docker Desktop Settings for SageMaker

## Step 1: Disable containerd in Docker Desktop

1. Open **Docker Desktop**
2. Click **Settings** (gear icon)
3. Go to **Features in development** (or **General** → **Features in development**)
4. **Disable** these options:
   - ❌ Use containerd for pulls
   - ❌ Use containerd for image storage
5. Click **Apply & Restart**

Wait for Docker Desktop to restart completely.

## Step 2: Rebuild Image with Docker Format

After Docker restarts, we'll rebuild the image with explicit Docker format.

