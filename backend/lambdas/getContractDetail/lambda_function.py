"""
Lambda function to fetch individual contract analysis details.
"""
import json
import boto3
import os
from typing import Dict, Any
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')

# Environment variables
CONTRACTS_TABLE = os.environ.get('CONTRACTS_TABLE', 'contract-ai-contracts-dev')
CLAUSES_TABLE = os.environ.get('CLAUSES_TABLE', 'contract-ai-clauses-dev')


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Fetch contract details and clauses from DynamoDB.
    
    Args:
        event: API Gateway event with contract_id in path
        context: Lambda context
        
    Returns:
        Contract analysis with clauses
    """
    try:
        # Extract contract_id from path
        contract_id = event.get('pathParameters', {}).get('id')
        if not contract_id:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({'error': 'Contract ID required'})
            }
        
        contracts_table = dynamodb.Table(CONTRACTS_TABLE)
        clauses_table = dynamodb.Table(CLAUSES_TABLE)
        
        # Get contract details
        contract_response = contracts_table.get_item(
            Key={'contract_id': contract_id}
        )
        
        if 'Item' not in contract_response:
            return {
                'statusCode': 404,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({'error': 'Contract not found'})
            }
        
        contract = contract_response['Item']
        
        # Get clauses for this contract
        clauses_response = clauses_table.scan(
            FilterExpression='contract_id = :id',
            ExpressionAttributeValues={':id': contract_id}
        )
        
        # Helper to convert DynamoDB types
        def convert_dynamodb_item(item):
            if isinstance(item, dict):
                if 'S' in item:
                    return item['S']
                elif 'N' in item:
                    return int(item['N']) if '.' not in item['N'] else float(item['N'])
            elif isinstance(item, Decimal):
                return int(item) if item % 1 == 0 else float(item)
            return item
        
        # Format clauses
        clauses = []
        for clause_item in clauses_response.get('Items', []):
            clauses.append({
                'name': convert_dynamodb_item(clause_item.get('clause_name', '')),
                'description': convert_dynamodb_item(clause_item.get('description', '')),
                'type': convert_dynamodb_item(clause_item.get('type', 'other'))
            })
        
        # Format contract response
        result = {
            'contract_id': convert_dynamodb_item(contract.get('contract_id', '')),
            'filename': convert_dynamodb_item(contract.get('filename', 'contract.pdf')),
            'summary': convert_dynamodb_item(contract.get('summary', '')),
            'clauses': clauses,
            'clauses_count': len(clauses),
            'status': convert_dynamodb_item(contract.get('status', 'processing')),
            'uploaded_at': convert_dynamodb_item(contract.get('uploaded_at', contract.get('created_at', ''))),
            'risk_score': convert_dynamodb_item(contract.get('risk_score', None)) if contract.get('risk_score') else None
        }
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(result)
        }
        
    except Exception as e:
        print(f"Error fetching contract details: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': str(e)})
        }

