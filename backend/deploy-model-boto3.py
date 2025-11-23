"""Deploy SageMaker model using boto3."""
import boto3
import time

sagemaker = boto3.client('sagemaker')
role_arn = 'arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/contract-ai-sagemaker-role-dev'
model_name = 'contract-risk-scorer-dev'
endpoint_name = 'contract-risk-scorer-dev'
config_name = f'{endpoint_name}-config'

# Model data
model_data_url = 's3://contract-ai-models-dev-YOUR_AWS_ACCOUNT_ID/risk-scorer/model.pkl'
image_uri = '763104351884.dkr.ecr.us-east-1.amazonaws.com/sklearn-inference:1.0-1-cpu-py3'

print("=== Deploying SageMaker Model ===")
print()

# Step 1: Create model
print("1. Creating SageMaker model...")
try:
    sagemaker.create_model(
        ModelName=model_name,
        ExecutionRoleArn=role_arn,
        PrimaryContainer={
            'Image': image_uri,
            'ModelDataUrl': model_data_url
        }
    )
    print(f"   [OK] Model created: {model_name}")
except Exception as e:
    if 'already exists' in str(e).lower():
        print(f"   [INFO] Model already exists")
    else:
        print(f"   [ERROR] {e}")
        print("\nTrying alternative: Deploy via AWS Console")
        print("See deploy-model-console.ps1 for instructions")
        exit(1)

# Step 2: Create endpoint configuration
print("2. Creating endpoint configuration...")
try:
    sagemaker.create_endpoint_config(
        EndpointConfigName=config_name,
        ProductionVariants=[{
            'VariantName': 'AllTraffic',
            'ModelName': model_name,
            'InitialInstanceCount': 1,
            'InstanceType': 'ml.t2.medium'
        }]
    )
    print(f"   [OK] Endpoint config created: {config_name}")
except Exception as e:
    if 'already exists' in str(e).lower():
        print(f"   [INFO] Config already exists")
    else:
        print(f"   [ERROR] {e}")
        exit(1)

# Step 3: Create or update endpoint
print("3. Creating/updating endpoint...")
try:
    # Check if endpoint exists
    try:
        response = sagemaker.describe_endpoint(EndpointName=endpoint_name)
        status = response['EndpointStatus']
        print(f"   [INFO] Endpoint exists with status: {status}")
        
        if status in ['Creating', 'Updating']:
            print(f"   [INFO] Endpoint is {status.lower()}, waiting...")
        elif status == 'InService':
            print(f"   [OK] Endpoint is already InService!")
        else:
            # Update endpoint
            print("   Updating endpoint...")
            sagemaker.update_endpoint(
                EndpointName=endpoint_name,
                EndpointConfigName=config_name
            )
            print(f"   [OK] Endpoint update started")
    except sagemaker.exceptions.ResourceNotFound:
        # Create new endpoint
        sagemaker.create_endpoint(
            EndpointName=endpoint_name,
            EndpointConfigName=config_name
        )
        print(f"   [OK] Endpoint creation started")
except Exception as e:
    print(f"   [ERROR] {e}")
    exit(1)

# Step 4: Wait and check status
print()
print("4. Waiting for endpoint to be ready...")
print("   (This takes 5-10 minutes)")
print()

max_wait = 600  # 10 minutes
start_time = time.time()

while True:
    try:
        response = sagemaker.describe_endpoint(EndpointName=endpoint_name)
        status = response['EndpointStatus']
        
        elapsed = int(time.time() - start_time)
        print(f"   Status: {status} (elapsed: {elapsed}s)", end='\r')
        
        if status == 'InService':
            print()
            print(f"   [OK] Endpoint is InService!")
            print()
            print(f"Endpoint ARN: {response['EndpointArn']}")
            break
        elif status in ['Failed', 'RollingBack']:
            print()
            print(f"   [ERROR] Endpoint status: {status}")
            print(f"   Reason: {response.get('FailureReason', 'Unknown')}")
            exit(1)
        
        if elapsed > max_wait:
            print()
            print(f"   [WARNING] Timeout after {max_wait}s")
            print(f"   Check status manually: aws sagemaker describe-endpoint --endpoint-name {endpoint_name}")
            break
        
        time.sleep(10)
    except KeyboardInterrupt:
        print()
        print("   [INFO] Interrupted. Check status later:")
        print(f"   aws sagemaker describe-endpoint --endpoint-name {endpoint_name}")
        break
    except Exception as e:
        print()
        print(f"   [ERROR] {e}")
        break

print()
print("[DONE] Model deployment complete!")

