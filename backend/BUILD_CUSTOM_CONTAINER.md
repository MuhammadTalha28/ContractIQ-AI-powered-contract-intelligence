# Build Custom SageMaker Container

## Overview
Build your own SageMaker container image and push it to your ECR repository to bypass the ECR permissions issue.

## Steps

### 1. Create Dockerfile
Create a Dockerfile for the SageMaker scikit-learn container:

```dockerfile
FROM python:3.9-slim

WORKDIR /opt/ml

# Install dependencies
RUN pip install --no-cache-dir scikit-learn==1.0.2 numpy pandas boto3

# Copy model and inference code
COPY model.pkl /opt/ml/model/model.pkl
COPY inference.py /opt/ml/code/inference.py

# Set environment variables
ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONONDONTWRITEBYTECODE=TRUE

# SageMaker expects the model at /opt/ml/model
# and code at /opt/ml/code
```

### 2. Create Inference Script
Create `inference.py`:

```python
import json
import pickle
import os
import numpy as np

def model_fn(model_dir):
    """Load model"""
    with open(os.path.join(model_dir, 'model.pkl'), 'rb') as f:
        model = pickle.load(f)
    return model

def input_fn(request_body, content_type):
    """Parse input"""
    if content_type == 'text/csv':
        features = [float(x) for x in request_body.split(',')]
        return np.array(features).reshape(1, -1)
    raise ValueError(f"Unsupported content type: {content_type}")

def predict_fn(input_data, model):
    """Make prediction"""
    prediction = model.predict(input_data)
    return {'predictions': [float(p) for p in prediction]}

def output_fn(prediction, accept):
    """Format output"""
    if accept == 'application/json':
        return json.dumps(prediction)
    return str(prediction['predictions'][0])
```

### 3. Build and Push to ECR

```powershell
# Get ECR login
$ECR_URI = "YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com"
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URI

# Build image
docker build -t risk-scorer:latest .

# Tag for ECR
docker tag risk-scorer:latest "$ECR_URI/risk-scorer:latest"

# Push to ECR
docker push "$ECR_URI/risk-scorer:latest"
```

### 4. Update SageMaker Model
Use your ECR image instead:
- Image: `YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/risk-scorer:latest`
- Model data: `s3://contract-ai-models-dev-YOUR_AWS_ACCOUNT_ID/risk-scorer/model.pkl`

## Alternative: Use System As-Is
The system is **fully functional** with fallback scoring. This is optional!

