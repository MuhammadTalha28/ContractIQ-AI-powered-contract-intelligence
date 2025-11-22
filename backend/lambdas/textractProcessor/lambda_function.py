"""
Lambda function to process documents with AWS Textract.
Extracts text from PDF contracts and saves to S3.
Falls back to PyPDF2 for free text extraction if Textract unavailable.
"""
import json
import boto3
import os
from typing import Dict, Any
import io
try:
    from PyPDF2 import PdfReader
    PYPDF2_AVAILABLE = True
    print("PyPDF2 successfully imported")
except ImportError as e:
    PYPDF2_AVAILABLE = False
    print(f"PyPDF2 import failed: {e}")

textract = boto3.client('textract')
s3_client = boto3.client('s3')
sqs = boto3.client('sqs')

# Environment variables
UPLOAD_BUCKET = os.environ.get('UPLOAD_BUCKET_NAME', 'contract-review-uploads')
TEXTRACT_BUCKET = os.environ.get('TEXTRACT_BUCKET_NAME', 'contract-textract-results')
SQS_QUEUE_URL = os.environ.get('SQS_QUEUE_URL')


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Process S3 event trigger to extract text from PDF using Textract.
    
    Args:
        event: S3 event from EventBridge
        context: Lambda context
        
    Returns:
        Status of text extraction
    """
    try:
        print(f"Received event: {json.dumps(event)}")
        
        # Handle EventBridge format (from S3 EventBridge notifications)
        if 'detail' in event:
            # EventBridge format
            detail = event.get('detail', {})
            bucket = detail.get('bucket', {}).get('name')
            key = detail.get('object', {}).get('key')
            
            if not bucket or not key:
                print("No bucket or key in EventBridge detail")
                return {'statusCode': 400, 'body': 'Invalid event format'}
        elif 'Records' in event:
            # Direct S3 notification format
            records = event.get('Records', [])
            if not records:
                return {'statusCode': 400, 'body': 'No records found'}
            
            record = records[0]
            bucket = record['s3']['bucket']['name']
            key = record['s3']['object']['key']
        else:
            print("Unknown event format")
            return {'statusCode': 400, 'body': 'Unknown event format'}
        
        # Process the file
        if bucket and key:
            
            # Skip if not a PDF
            if not key.lower().endswith('.pdf'):
                print(f"Skipping non-PDF file: {key}")
                return {'statusCode': 200, 'body': 'Not a PDF file'}
            
            print(f"Processing document: s3://{bucket}/{key}")
            
            # Extract contract ID first (needed for both paths)
            contract_id = extract_contract_id_from_key(key)
            
            # Try Textract first (paid service)
            use_free_extraction = False
            try:
                response = textract.start_document_text_detection(
                    DocumentLocation={
                        'S3Object': {
                            'Bucket': bucket,
                            'Name': key
                        }
                    }
                )
                job_id = response['JobId']
                print(f"Textract job started: {job_id}")
            except Exception as e:
                if 'SubscriptionRequiredException' in str(e) or 'AccessDeniedException' in str(e):
                    # Textract not available - use free PDF extraction
                    print("Textract not available, using free PDF extraction (PyPDF2)")
                    use_free_extraction = True
                    job_id = f"free-extraction-{contract_id}"
                else:
                    raise
            
            # Free alternative: Extract text using PyPDF2 (if Textract unavailable)
            if use_free_extraction:
                extracted_text = extract_text_from_pdf_free(bucket, key)
                # Save extracted text
                s3_client.put_object(
                    Bucket=TEXTRACT_BUCKET,
                    Key=f"extracted-text/{contract_id}/text.txt",
                    Body=extracted_text,
                    ContentType='text/plain'
                )
                print(f"Text extracted using free method, saved to S3")
            
            # Save job metadata
            metadata = {
                'job_id': job_id,
                'contract_id': contract_id,
                's3_key': key,
                'status': 'processing',
                'bucket': bucket
            }
            
            metadata_key = f"textract-jobs/{contract_id}/metadata.json"
            s3_client.put_object(
                Bucket=TEXTRACT_BUCKET,
                Key=metadata_key,
                Body=json.dumps(metadata),
                ContentType='application/json'
            )
            
            # Send message to SQS for async processing
            if SQS_QUEUE_URL:
                sqs.send_message(
                    QueueUrl=SQS_QUEUE_URL,
                    MessageBody=json.dumps({
                        'job_id': job_id,
                        'contract_id': contract_id,
                        's3_key': key,
                        'bucket': bucket
                    })
                )
            
            print(f"Textract job started: {job_id} for contract {contract_id}")
            
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'Textract processing initiated', 'job_id': job_id})
            }
        else:
            return {'statusCode': 400, 'body': 'Missing bucket or key'}
        
    except Exception as e:
        print(f"Error in textract processor: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }


def extract_text_from_pdf_free(bucket: str, key: str) -> str:
    """
    Extract text from PDF using free method (PyPDF2).
    This is a fallback when Textract is not available.
    """
    try:
        # Download PDF from S3
        pdf_obj = s3_client.get_object(Bucket=bucket, Key=key)
        pdf_bytes = pdf_obj['Body'].read()
        
        print(f"PYPDF2_AVAILABLE: {PYPDF2_AVAILABLE}")
        if not PYPDF2_AVAILABLE:
            print("PyPDF2 not available, returning placeholder")
            return f"[PDF extracted using free method]\nFile: {key}\nSize: {len(pdf_bytes)} bytes\n\nNote: PyPDF2 not installed. Install PyPDF2 in Lambda layer for actual text extraction."
        
        # Extract text using PyPDF2
        pdf_file = io.BytesIO(pdf_bytes)
        reader = PdfReader(pdf_file)
        
        text_parts = []
        for page_num, page in enumerate(reader.pages, 1):
            try:
                page_text = page.extract_text()
                if page_text.strip():
                    text_parts.append(page_text)
            except Exception as e:
                print(f"Error extracting page {page_num}: {e}")
                continue
        
        extracted_text = "\n\n".join(text_parts)
        
        if not extracted_text.strip():
            return f"[PDF extracted using free method]\nFile: {key}\nSize: {len(pdf_bytes)} bytes\n\nNote: No text could be extracted from this PDF. It may be image-based or encrypted. Consider using Textract (paid) for better accuracy."
        
        return extracted_text
        
    except Exception as e:
        print(f"Error in free extraction: {e}")
        return f"Error extracting text: {str(e)}"


def extract_contract_id_from_key(key: str) -> str:
    """Extract contract ID from S3 key path."""
    parts = key.split('/')
    if len(parts) >= 3 and parts[0] == 'contracts':
        return parts[2]  # contracts/{user_id}/{contract_id}/filename.pdf
    return key.split('/')[-1].replace('.pdf', '')

