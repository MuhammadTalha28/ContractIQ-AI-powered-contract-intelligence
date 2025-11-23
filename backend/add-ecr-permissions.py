"""Add ECR permissions to SageMaker role."""
import boto3
import json

iam = boto3.client('iam')

ecr_policy = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage"
            ],
            "Resource": "*"
        }
    ]
}

role_name = 'contract-ai-sagemaker-role-dev'

try:
    iam.put_role_policy(
        RoleName=role_name,
        PolicyName='ECRAccess',
        PolicyDocument=json.dumps(ecr_policy)
    )
    print("ECR permissions added")
except Exception as e:
    print(f"Error: {e}")

