"""One-time script to enable Bedrock model account-wide."""
import json
import boto3

bedrock_runtime = boto3.client('bedrock-runtime', region_name='us-east-1')
model_id = 'anthropic.claude-3-sonnet-20240229-v1:0'

print("=== Enabling Bedrock Model (One-Time) ===")
print("Invoking Claude 3 Sonnet to enable it account-wide...")
print()

try:
    response = bedrock_runtime.invoke_model(
        modelId=model_id,
        body=json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 100,
            "messages": [
                {
                    "role": "user",
                    "content": "Hello, this is a test to enable the model."
                }
            ]
        }),
        contentType='application/json',
        accept='application/json'
    )
    
    response_body = json.loads(response['body'].read())
    print("[SUCCESS] Model enabled! The Lambda role can now use it.")
    print()
    print("Response preview:")
    print(json.dumps(response_body, indent=2))
    
except Exception as e:
    print(f"[ERROR] Failed to enable model: {e}")
    print()
    print("You may need to:")
    print("  1. Submit use case details in Bedrock console")
    print("  2. Wait 10-15 minutes for processing")
    print("  3. Ensure your AWS CLI credentials have Marketplace permissions")

