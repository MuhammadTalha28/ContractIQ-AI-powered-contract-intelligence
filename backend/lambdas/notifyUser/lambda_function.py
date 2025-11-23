"""
Lambda function to send notifications via SNS when contract analysis is complete.
"""
import json
import boto3
import os
from typing import Dict, Any

sns = boto3.client('sns')
dynamodb = boto3.resource('dynamodb')

# Environment variables
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')
CONTRACTS_TABLE = os.environ.get('CONTRACTS_TABLE', 'contracts')


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Send notification when contract analysis is complete.
    
    Args:
        event: Event containing contract_id
        context: Lambda context
        
    Returns:
        Notification status
    """
    try:
        # Extract contract ID
        contract_id = event.get('contract_id')
        if not contract_id:
            # Try to get from SQS event
            records = event.get('Records', [])
            if records:
                message_body = json.loads(records[0]['body'])
                contract_id = message_body.get('contract_id')
        
        if not contract_id:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'contract_id required'})
            }
        
        # Get contract details from DynamoDB
        contracts_table = dynamodb.Table(CONTRACTS_TABLE)
        contract = contracts_table.get_item(Key={'contract_id': contract_id})
        
        if 'Item' not in contract:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': 'Contract not found'})
            }
        
        contract_item = contract['Item']
        user_id = contract_item.get('user_id', 'unknown')
        filename = contract_item.get('filename', 'contract.pdf')
        risk_score = contract_item.get('risk_score')
        status = contract_item.get('status', 'unknown')
        
        # Only send notification if analysis is complete
        if status not in ['completed', 'analyzed']:
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'Analysis not complete, skipping notification'})
            }
        
        # Prepare notification message
        risk_level = get_risk_level(risk_score) if risk_score is not None else 'N/A'
        message = f"""Your contract analysis is complete!

Contract: {filename}
Risk Score: {risk_score}/100 ({risk_level})
Status: {status}

View full analysis in your dashboard.
"""
        
        # Send SNS notification
        if SNS_TOPIC_ARN:
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject=f'Contract Analysis Complete: {filename}',
                Message=message,
                MessageAttributes={
                    'contract_id': {
                        'DataType': 'String',
                        'StringValue': contract_id
                    },
                    'user_id': {
                        'DataType': 'String',
                        'StringValue': user_id
                    }
                }
            )
            print(f"Notification sent for contract {contract_id}")
        else:
            print("SNS_TOPIC_ARN not configured, skipping notification")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Notification sent',
                'contract_id': contract_id
            })
        }
        
    except Exception as e:
        print(f"Error sending notification: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }


def get_risk_level(score: float) -> str:
    """Convert numeric score to risk level."""
    if score is None:
        return 'N/A'
    if score >= 70:
        return 'High Risk'
    elif score >= 40:
        return 'Medium Risk'
    else:
        return 'Low Risk'

