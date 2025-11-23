"""
Lambda function to analyze contracts using AWS Bedrock (Claude 3).
Extracts clauses, identifies risks, and generates summaries.
"""
import json
import boto3
import os
from datetime import datetime
from typing import Dict, Any, List

bedrock_runtime = boto3.client('bedrock-runtime', region_name='us-east-1')
s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
lambda_client = boto3.client('lambda')

# Environment variables
TEXTRACT_BUCKET = os.environ.get('TEXTRACT_BUCKET_NAME', 'contract-textract-results')
BEDROCK_MODEL_ID = os.environ.get('BEDROCK_MODEL_ID', 'anthropic.claude-3-sonnet-20240229-v1:0')
CONTRACTS_TABLE = os.environ.get('CONTRACTS_TABLE', 'contracts')
CLAUSES_TABLE = os.environ.get('CLAUSES_TABLE', 'clauses')


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Analyze contract text using Bedrock LLM.
    
    Args:
        event: SQS event containing contract text location
        context: Lambda context
        
    Returns:
        Analysis results
    """
    try:
        # Parse SQS event
        records = event.get('Records', [])
        if not records:
            return {'statusCode': 400, 'body': 'No records found'}
        
        for record in records:
            # Parse SQS message body (may be string or already parsed)
            body = record.get('body', '{}')
            if isinstance(body, str):
                try:
                    # Strip BOM (Byte Order Mark) if present
                    if body.startswith('\ufeff'):
                        body = body[1:]
                    # Also handle UTF-8 BOM bytes
                    if body.startswith('\xef\xbb\xbf'):
                        body = body[3:]
                    message_body = json.loads(body)
                except json.JSONDecodeError as e:
                    print(f"Failed to parse message body: {e}")
                    print(f"Body content: {body[:200]}")
                    continue
            else:
                message_body = body
            
            contract_id = message_body.get('contract_id')
            textract_text = message_body.get('extracted_text', '')
            
            if not textract_text:
                # Fetch from S3 if not in message
                text_key = f"extracted-text/{contract_id}/text.txt"
                try:
                    response = s3_client.get_object(
                        Bucket=TEXTRACT_BUCKET,
                        Key=text_key
                    )
                    textract_text = response['Body'].read().decode('utf-8')
                except Exception as e:
                    print(f"Could not fetch text from S3: {e}")
                    continue
            
            # Analyze with Bedrock
            analysis = analyze_contract_with_bedrock(textract_text)
            
            # Save results to DynamoDB
            save_analysis_results(contract_id, analysis)
            
            # Update contract status
            update_contract_status(contract_id, 'analyzed', analysis)
            
            # Trigger risk scoring (async)
            try:
                trigger_risk_scoring(contract_id, analysis)
            except Exception as e:
                print(f"Failed to trigger risk scoring: {e}")
            
            print(f"Analysis completed for contract {contract_id}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Analysis completed'})
        }
        
    except Exception as e:
        print(f"Error in bedrock analyzer: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }


def analyze_contract_with_bedrock(contract_text: str) -> Dict[str, Any]:
    """
    Use Bedrock Claude to analyze contract.
    
    Args:
        contract_text: Extracted text from Textract
        
    Returns:
        Analysis results dictionary
    """
    prompt = f"""You are an enterprise contract review assistant. Analyze the following contract text and extract:

1. **Clauses List**: Extract all major clauses (payment terms, liability, confidentiality, termination, etc.)
2. **Payment Terms**: Identify payment amounts, schedules, penalties
3. **Liability**: Identify liability limitations, indemnification clauses
4. **Confidentiality**: Extract confidentiality and NDA terms
5. **Termination Conditions**: Identify termination clauses and conditions
6. **Hidden Risks**: List any concerning or unusual clauses
7. **Missing Clauses**: Identify critical clauses that should be present but are missing
8. **Summary**: Provide a 2-3 sentence executive summary

Contract Text:
{contract_text[:50000]}  # Limit to 50k chars for Bedrock

Respond in JSON format:
{{
  "clauses": [
    {{"name": "clause name", "description": "clause description", "type": "payment|liability|confidentiality|termination|other"}}
  ],
  "payment_terms": {{"amount": "...", "schedule": "...", "penalties": "..."}},
  "liability": "description of liability terms",
  "confidentiality": "description of confidentiality terms",
  "termination": "description of termination conditions",
  "hidden_risks": ["risk 1", "risk 2"],
  "missing_clauses": ["clause 1", "clause 2"],
  "summary": "executive summary"
}}
"""
    
    try:
        response = bedrock_runtime.invoke_model(
            modelId=BEDROCK_MODEL_ID,
            body=json.dumps({
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 4000,
                "messages": [
                    {
                        "role": "user",
                        "content": prompt
                    }
                ]
            }),
            contentType='application/json',
            accept='application/json'
        )
        
        response_body = json.loads(response['body'].read())
        content = response_body.get('content', [])
        
        if content and len(content) > 0:
            analysis_text = content[0].get('text', '')
            # Parse JSON from response (may be wrapped in markdown code blocks)
            try:
                # Remove markdown code blocks if present
                cleaned_text = analysis_text.strip()
                if cleaned_text.startswith('```json'):
                    cleaned_text = cleaned_text[7:]  # Remove ```json
                if cleaned_text.startswith('```'):
                    cleaned_text = cleaned_text[3:]   # Remove ```
                if cleaned_text.endswith('```'):
                    cleaned_text = cleaned_text[:-3]  # Remove trailing ```
                cleaned_text = cleaned_text.strip()
                
                parsed = json.loads(cleaned_text)
                print(f"Successfully parsed Bedrock response with {len(parsed.get('clauses', []))} clauses")
                return parsed
            except json.JSONDecodeError as e:
                print(f"Failed to parse JSON: {e}")
                print(f"Response text: {analysis_text[:200]}")
                # Fallback: return structured response
                return {
                    'clauses': [],
                    'summary': analysis_text[:500],
                    'raw_analysis': analysis_text
                }
        else:
            return {'error': 'No analysis generated'}
            
    except Exception as e:
        print(f"Bedrock API error: {e}")
        return {'error': str(e)}


def save_analysis_results(contract_id: str, analysis: Dict[str, Any]) -> None:
    """Save analysis results to DynamoDB."""
    clauses_table = dynamodb.Table(CLAUSES_TABLE)
    
    # Save each clause
    for clause in analysis.get('clauses', []):
        clauses_table.put_item(
            Item={
                'clause_id': f"{contract_id}_{clause.get('name', 'unknown')}",
                'contract_id': contract_id,
                'clause_name': clause.get('name', ''),
                'description': clause.get('description', ''),
                'type': clause.get('type', 'other'),
                'created_at': datetime.utcnow().isoformat()
            }
        )


def update_contract_status(contract_id: str, status: str, analysis: Dict[str, Any]) -> None:
    """Update contract status in DynamoDB."""
    contracts_table = dynamodb.Table(CONTRACTS_TABLE)
    
    update_expression = "SET #status = :status, clauses_count = :clauses_count, summary = :summary"
    expression_values = {
        ':status': status,
        ':clauses_count': len(analysis.get('clauses', [])),
        ':summary': analysis.get('summary', '')[:500]
    }
    expression_names = {'#status': 'status'}
    
    contracts_table.update_item(
        Key={'contract_id': contract_id},
        UpdateExpression=update_expression,
        ExpressionAttributeValues=expression_values,
        ExpressionAttributeNames=expression_names
    )


def trigger_risk_scoring(contract_id: str, analysis: Dict[str, Any]) -> None:
    """Trigger risk scoring Lambda asynchronously."""
    try:
        lambda_client.invoke(
            FunctionName='contract-ai-sage-maker-scorer-dev',
            InvocationType='Event',  # Async
            Payload=json.dumps({
                'contract_id': contract_id,
                'analysis': analysis
            })
        )
        print(f"Risk scoring triggered for contract {contract_id}")
    except Exception as e:
        print(f"Failed to trigger risk scoring: {e}")

