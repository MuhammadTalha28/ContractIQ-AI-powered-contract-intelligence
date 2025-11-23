"""
Lambda function to fetch contracts from DynamoDB.
"""
import json
import boto3
import os
from typing import Dict, Any
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')

# Environment variables
CONTRACTS_TABLE = os.environ.get('CONTRACTS_TABLE', 'contract-ai-contracts-dev')


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Fetch all contracts from DynamoDB.
    
    Args:
        event: API Gateway event
        context: Lambda context
        
    Returns:
        List of contracts
    """
    try:
        contracts_table = dynamodb.Table(CONTRACTS_TABLE)
        
        # Scan all contracts
        response = contracts_table.scan()
        contracts = response.get('Items', [])
        
        # Helper to convert DynamoDB types
        def convert_dynamodb_item(item):
            """Convert DynamoDB item to Python dict."""
            if isinstance(item, dict):
                if 'S' in item:
                    return item['S']
                elif 'N' in item:
                    return int(item['N']) if '.' not in item['N'] else float(item['N'])
                elif 'M' in item:
                    return {k: convert_dynamodb_item(v) for k, v in item['M'].items()}
            elif isinstance(item, Decimal):
                return int(item) if item % 1 == 0 else float(item)
            return item
        
        # Format contracts for frontend
        formatted_contracts = []
        for contract in contracts:
            # Convert DynamoDB types
            contract_id = convert_dynamodb_item(contract.get('contract_id', ''))
            filename = convert_dynamodb_item(contract.get('filename', 'contract.pdf'))
            uploaded_at = convert_dynamodb_item(contract.get('uploaded_at', contract.get('created_at', '')))
            status = convert_dynamodb_item(contract.get('status', 'processing'))
            clauses_count = convert_dynamodb_item(contract.get('clauses_count', 0))
            summary = convert_dynamodb_item(contract.get('summary', ''))
            risk_score = convert_dynamodb_item(contract.get('risk_score', None)) if contract.get('risk_score') else None
            
            formatted_contracts.append({
                'id': contract_id,
                'filename': filename,
                'uploadedAt': uploaded_at,
                'status': status,
                'riskScore': risk_score,
                'clausesCount': clauses_count,
                'summary': summary
            })
        
        # Sort by uploaded date (newest first)
        formatted_contracts.sort(key=lambda x: x.get('uploadedAt', ''), reverse=True)
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(formatted_contracts)
        }
        
    except Exception as e:
        print(f"Error fetching contracts: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': str(e)})
        }

