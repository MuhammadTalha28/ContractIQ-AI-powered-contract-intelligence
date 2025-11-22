"""Enable Bedrock model account-wide using user credentials."""
import json
import boto3

print("=== Enabling Bedrock Model Account-Wide ===")
print()
print("Invoking Claude 3 Sonnet with your user credentials...")
print("This will enable it account-wide so Lambda can use it.")
print()

bedrock_runtime = boto3.client('bedrock-runtime', region_name='us-east-1')
model_id = 'anthropic.claude-3-sonnet-20240229-v1:0'

try:
    response = bedrock_runtime.invoke_model(
        modelId=model_id,
        body=json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 100,
            "messages": [
                {
                    "role": "user",
                    "content": "Hello, enabling model for account."
                }
            ]
        }),
        contentType='application/json',
        accept='application/json'
    )
    
    response_body = json.loads(response['body'].read())
    print("[SUCCESS] Model enabled account-wide!")
    print()
    print("Response preview:")
    print(json.dumps(response_body, indent=2))
    print()
    print("Now test the Lambda pipeline:")
    print("  .\\test-pipeline.ps1")
    
except Exception as e:
    error_str = str(e)
    print(f"[ERROR] Failed to invoke model: {error_str}")
    print()
    
    if "AccessDeniedException" in error_str:
        print("Possible issues:")
        print("  1. Your AWS credentials may not have Marketplace permissions")
        print("  2. Use case details may not be fully processed yet")
        print("  3. Check Bedrock console: https://us-east-1.console.aws.amazon.com/bedrock")
    elif "ResourceNotFoundException" in error_str:
        print("Model not found. Check the model ID.")
    else:
        print(f"Unexpected error: {error_str}")

