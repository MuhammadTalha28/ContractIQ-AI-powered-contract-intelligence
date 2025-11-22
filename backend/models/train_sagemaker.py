"""
Script to train and deploy SageMaker model.
Run this to create the SageMaker endpoint.
"""
import boto3
import sagemaker
from sagemaker.sklearn.estimator import SKLearn
import os

# SageMaker session
sagemaker_session = sagemaker.Session()
role = os.environ.get('SAGEMAKER_ROLE_ARN', 'arn:aws:iam::ACCOUNT:role/SageMakerExecutionRole')

# Create estimator
estimator = SKLearn(
    entry_point='risk_scorer_model.py',
    role=role,
    instance_type='ml.m5.large',
    framework_version='1.0-1',
    py_version='py3',
    sagemaker_session=sagemaker_session,
    output_path='s3://contract-ai-models/output',
    code_location='s3://contract-ai-models/code'
)

# Train model
estimator.fit({'training': 's3://contract-ai-models/training'})

# Deploy endpoint
predictor = estimator.deploy(
    initial_instance_count=1,
    instance_type='ml.t2.medium',
    endpoint_name='contract-risk-scorer'
)

print(f"Model deployed to endpoint: {predictor.endpoint_name}")

