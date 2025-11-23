"""
Lambda function to calculate risk scores using SageMaker ML model.
Calls SageMaker endpoint with contract features and returns risk score (0-100).
"""
import json
import boto3
import os
from datetime import datetime
from decimal import Decimal
from typing import Dict, Any

sagemaker_runtime = boto3.client('sagemaker-runtime')
dynamodb = boto3.resource('dynamodb')
lambda_client = boto3.client('lambda')

# Environment variables
SAGEMAKER_ENDPOINT = os.environ.get('SAGEMAKER_ENDPOINT_NAME', 'contract-risk-scorer')
CONTRACTS_TABLE = os.environ.get('CONTRACTS_TABLE', 'contracts')


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Calculate risk score for a contract using SageMaker model.
    
    Args:
        event: Event containing contract_id and analysis features
        context: Lambda context
        
    Returns:
        Risk score (0-100)
    """
    try:
        # Extract contract ID and features
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
        
        # Get contract analysis from DynamoDB
        contracts_table = dynamodb.Table(CONTRACTS_TABLE)
        contract = contracts_table.get_item(Key={'contract_id': contract_id})
        
        if 'Item' not in contract:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': 'Contract not found'})
            }
        
        contract_item = contract['Item']
        
        # Extract features for ML model
        features = extract_features(contract_item, event.get('analysis', {}))
        
        # Call SageMaker endpoint
        risk_score = call_sagemaker_endpoint(features)
        
        # Update contract with risk score (convert to Decimal for DynamoDB)
        contracts_table.update_item(
            Key={'contract_id': contract_id},
            UpdateExpression='SET risk_score = :score, risk_calculated_at = :timestamp, #status = :status',
            ExpressionAttributeValues={
                ':score': Decimal(str(round(risk_score, 2))),
                ':timestamp': datetime.utcnow().isoformat(),
                ':status': 'completed'
            },
            ExpressionAttributeNames={'#status': 'status'}
        )
        
        # Trigger notification
        try:
            trigger_notification(contract_id)
        except Exception as e:
            print(f"Failed to trigger notification: {e}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'contract_id': contract_id,
                'risk_score': risk_score,
                'risk_level': get_risk_level(risk_score)
            })
        }
        
    except Exception as e:
        print(f"Error calculating risk score: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }


def extract_features(contract_item: Dict[str, Any], analysis: Dict[str, Any]) -> Dict[str, Any]:
    """
    Extract features from contract for ML model.
    
    Features:
    - Contract length (word count)
    - Number of clauses
    - Number of risky keywords
    - Missing critical clauses count
    - Penalty terms presence
    - Liability limitations
    """
    clauses_count = contract_item.get('clauses_count', 0)
    
    # Extract from analysis if available
    hidden_risks = len(analysis.get('hidden_risks', []))
    missing_clauses = len(analysis.get('missing_clauses', []))
    
    # Calculate risky keywords (simplified)
    risky_keywords = count_risky_keywords(contract_item.get('summary', ''))
    
    # Check for penalty terms
    has_penalties = 'penalty' in contract_item.get('summary', '').lower() or \
                   'penalty' in str(analysis.get('payment_terms', {})).lower()
    
    # Liability score (0-1)
    liability_score = 0.5  # Default, would be calculated from analysis
    
    return {
        'clauses_count': clauses_count,
        'risky_keywords': risky_keywords,
        'missing_clauses': missing_clauses,
        'hidden_risks': hidden_risks,
        'has_penalties': 1 if has_penalties else 0,
        'liability_score': liability_score
    }


def count_risky_keywords(text: str) -> int:
    """Count occurrences of risky keywords in text."""
    risky_terms = [
        'penalty', 'forfeit', 'liquidated damages', 'indemnify',
        'unlimited liability', 'waiver', 'exclusive', 'binding arbitration'
    ]
    text_lower = text.lower()
    return sum(1 for term in risky_terms if term in text_lower)


def call_sagemaker_endpoint(features: Dict[str, Any]) -> float:
    """
    Call SageMaker endpoint to get risk score.
    
    Args:
        features: Feature dictionary
        
    Returns:
        Risk score (0-100)
    """
    try:
        # Format features as CSV for model
        feature_vector = [
            features['clauses_count'],
            features['risky_keywords'],
            features['missing_clauses'],
            features['hidden_risks'],
            features['has_penalties'],
            features['liability_score']
        ]
        
        csv_data = ','.join(map(str, feature_vector))
        
        response = sagemaker_runtime.invoke_endpoint(
            EndpointName=SAGEMAKER_ENDPOINT,
            ContentType='text/csv',
            Body=csv_data
        )
        
        result = json.loads(response['Body'].read().decode())
        risk_score = float(result.get('predictions', [result])[0] if isinstance(result, dict) else result)
        
        # Ensure score is between 0-100
        return max(0, min(100, risk_score))
        
    except Exception as e:
        print(f"SageMaker endpoint error: {e}")
        # Fallback: calculate simple risk score
        return calculate_fallback_risk_score(features)


def calculate_fallback_risk_score(features: Dict[str, Any]) -> float:
    """Calculate risk score without SageMaker (fallback)."""
    base_score = 20.0
    
    # Add risk based on features
    base_score += features['risky_keywords'] * 5
    base_score += features['missing_clauses'] * 3
    base_score += features['hidden_risks'] * 10
    base_score += features['has_penalties'] * 15
    base_score += features['liability_score'] * 20
    
    return min(100, base_score)


def get_risk_level(score: float) -> str:
    """Convert numeric score to risk level."""
    if score >= 70:
        return 'high'
    elif score >= 40:
        return 'medium'
    else:
        return 'low'


def trigger_notification(contract_id: str) -> None:
    """Trigger notification Lambda asynchronously."""
    try:
        lambda_client.invoke(
            FunctionName='contract-ai-notify-user-dev',
            InvocationType='Event',  # Async
            Payload=json.dumps({
                'contract_id': contract_id
            })
        )
        print(f"Notification triggered for contract {contract_id}")
    except Exception as e:
        print(f"Failed to trigger notification: {e}")

