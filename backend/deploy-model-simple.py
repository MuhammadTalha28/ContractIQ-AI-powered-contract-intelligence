"""Deploy SageMaker model using Python SDK."""
import boto3
import sagemaker
from sagemaker.sklearn.model import SKLearnModel
import os

# SageMaker session
sagemaker_session = sagemaker.Session()
role = 'arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/contract-ai-sagemaker-role-dev'

# Model data location
model_data = 's3://contract-ai-models-dev-YOUR_AWS_ACCOUNT_ID/risk-scorer/model.pkl'

# Create model
sklearn_model = SKLearnModel(
    model_data=model_data,
    role=role,
    entry_point='risk_scorer_model.py',
    framework_version='1.0-1',
    py_version='py3',
    sagemaker_session=sagemaker_session
)

# Deploy endpoint
print("Deploying endpoint (this takes 5-10 minutes)...")
predictor = sklearn_model.deploy(
    initial_instance_count=1,
    instance_type='ml.t2.medium',
    endpoint_name='contract-risk-scorer-dev'
)

print(f"Endpoint deployed: {predictor.endpoint_name}")
print(f"Endpoint ARN: {predictor.endpoint_arn}")

