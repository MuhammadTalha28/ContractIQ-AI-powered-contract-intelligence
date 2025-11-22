"""
Lambda function to handle contract uploads.
Uploads file to S3 and triggers the processing pipeline.
"""
import json
import boto3
import os
import uuid
from datetime import datetime
from typing import Dict, Any

s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

# Environment variables
BUCKET_NAME = os.environ.get('UPLOAD_BUCKET_NAME', 'contract-review-uploads')
CONTRACTS_TABLE = os.environ.get('CONTRACTS_TABLE', 'contracts')


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Handle contract upload request.
    
    Args:
        event: API Gateway event containing file data
        context: Lambda context
        
    Returns:
        Response with contract ID and upload status
    """
    try:
        # Parse request body
        if event.get('isBase64Encoded'):
            import base64
            body = base64.b64decode(event['body'])
        else:
            body = event.get('body', '{}')
        
        if isinstance(body, str):
            body = json.loads(body)
        
        # Extract file data (in production, use multipart/form-data parsing)
        file_content = body.get('file_content')
        filename = body.get('filename', 'contract.pdf')
        user_id = event.get('requestContext', {}).get('authorizer', {}).get('userId', 'anonymous')
        
        if not file_content:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({'error': 'No file content provided'})
            }
        
        # Generate unique contract ID
        contract_id = str(uuid.uuid4())
        s3_key = f"contracts/{user_id}/{contract_id}/{filename}"
        
        # Upload to S3
        import base64
        file_bytes = base64.b64decode(file_content)
        s3_client.put_object(
            Bucket=BUCKET_NAME,
            Key=s3_key,
            Body=file_bytes,
            ContentType='application/pdf',
            Metadata={
                'contract-id': contract_id,
                'user-id': user_id,
                'uploaded-at': datetime.utcnow().isoformat()
            }
        )
        
        # Create contract record in DynamoDB
        contracts_table = dynamodb.Table(CONTRACTS_TABLE)
        contracts_table.put_item(
            Item={
                'contract_id': contract_id,
                'user_id': user_id,
                'filename': filename,
                's3_key': s3_key,
                'status': 'uploaded',
                'uploaded_at': datetime.utcnow().isoformat(),
                'created_at': datetime.utcnow().isoformat()
            }
        )
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'contractId': contract_id,
                'message': 'Contract uploaded successfully',
                'status': 'uploaded'
            })
        }
        
    except Exception as e:
        print(f"Error processing upload: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': 'Internal server error'})
        }

