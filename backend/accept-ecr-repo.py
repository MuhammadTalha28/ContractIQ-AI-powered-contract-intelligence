"""Try to accept ECR repository terms."""
import boto3
import json

# Try to accept the repository terms
ecr = boto3.client('ecr', region_name='us-east-1')
ecr_public = boto3.client('ecr-public', region_name='us-east-1')

repo_uri = '763104351884.dkr.ecr.us-east-1.amazonaws.com/sklearn-inference'

print("Attempting to accept ECR repository terms...")
print(f"Repository: {repo_uri}")
print()

# Try different methods
methods = [
    ("ECR Public API", lambda: ecr_public.describe_repositories()),
    ("ECR API", lambda: ecr.describe_repositories()),
]

for method_name, method_func in methods:
    try:
        print(f"Trying {method_name}...")
        result = method_func()
        print(f"  [OK] {method_name} works")
    except Exception as e:
        print(f"  [INFO] {method_name}: {e}")

print()
print("Note: ECR repository terms typically need to be accepted via AWS Console")
print("when first using SageMaker containers. The console automatically handles this.")
print()
print("Alternative: Use AWS Console to deploy (see deploy-and-test-model.ps1)")

