"""Create SageMaker execution role."""
import boto3
import json

iam = boto3.client('iam')

trust_policy = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "sagemaker.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}

role_name = 'contract-ai-sagemaker-role-dev'

try:
    # Create role
    response = iam.create_role(
        RoleName=role_name,
        AssumeRolePolicyDocument=json.dumps(trust_policy),
        Description='SageMaker execution role for contract AI'
    )
    print(f"Role created: {role_name}")
    
    # Attach policies
    iam.attach_role_policy(
        RoleName=role_name,
        PolicyArn='arn:aws:iam::aws:policy/AmazonSageMakerFullAccess'
    )
    print("Attached SageMakerFullAccess policy")
    
    iam.attach_role_policy(
        RoleName=role_name,
        PolicyArn='arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly'
    )
    print("Attached ECR read-only policy")
    
    print(f"\nRole ARN: {response['Role']['Arn']}")
    
except iam.exceptions.EntityAlreadyExistsException:
    print(f"Role {role_name} already exists")
except Exception as e:
    print(f"Error: {e}")

