# API Documentation

## Base URL

Production: `https://api.contract-ai.example.com`  
Development: `https://YOUR-API-GATEWAY-ID.execute-api.us-east-1.amazonaws.com/dev`

## Authentication

All endpoints (except `/auth/*`) require authentication via JWT token in the Authorization header:

```
Authorization: Bearer <token>
```

## Endpoints

### Authentication

#### POST /auth/register
Register a new user.

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "securepassword",
  "full_name": "John Doe",
  "company": "Acme Corp"
}
```

**Response**:
```json
{
  "token": "jwt-token-here",
  "user": {
    "user_id": "uuid",
    "email": "user@example.com",
    "full_name": "John Doe"
  }
}
```

#### POST /auth/login
Login with email and password.

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response**:
```json
{
  "token": "jwt-token-here",
  "user": {
    "user_id": "uuid",
    "email": "user@example.com"
  }
}
```

### Contracts

#### POST /upload
Upload a contract for analysis.

**Request**:
- Content-Type: `multipart/form-data`
- Body: Form data with `file` field (PDF)

**Response**:
```json
{
  "contractId": "uuid",
  "message": "Contract uploaded successfully",
  "status": "uploaded"
}
```

#### GET /contracts
Get all contracts for the authenticated user.

**Query Parameters**:
- `limit` (optional): Number of results (default: 20)
- `offset` (optional): Pagination offset (default: 0)
- `status` (optional): Filter by status (uploaded, processing, completed, failed)

**Response**:
```json
{
  "contracts": [
    {
      "contract_id": "uuid",
      "filename": "contract.pdf",
      "status": "completed",
      "uploaded_at": "2024-01-15T10:30:00Z",
      "risk_score": 65,
      "clauses_count": 12,
      "summary": "Contract summary..."
    }
  ],
  "total": 10,
  "limit": 20,
  "offset": 0
}
```

#### GET /contracts/{contractId}
Get detailed information about a specific contract.

**Response**:
```json
{
  "contract_id": "uuid",
  "filename": "contract.pdf",
  "status": "completed",
  "uploaded_at": "2024-01-15T10:30:00Z",
  "risk_score": 65,
  "risk_level": "medium",
  "clauses_count": 12,
  "summary": "Contract summary...",
  "clauses": [
    {
      "clause_id": "uuid",
      "clause_name": "Payment Terms",
      "description": "Payment due within 30 days",
      "type": "payment"
    }
  ],
  "payment_terms": {
    "amount": "$10,000",
    "schedule": "Monthly",
    "penalties": "5% late fee"
  },
  "liability": "Limited liability up to contract value",
  "confidentiality": "Standard NDA terms apply",
  "termination": "Either party may terminate with 30 days notice",
  "hidden_risks": [
    "Unusual penalty clause",
    "Binding arbitration requirement"
  ],
  "missing_clauses": [
    "Force majeure clause",
    "Dispute resolution"
  ]
}
```

#### DELETE /contracts/{contractId}
Delete a contract and all associated data.

**Response**:
```json
{
  "message": "Contract deleted successfully",
  "contract_id": "uuid"
}
```

### Clauses

#### GET /contracts/{contractId}/clauses
Get all clauses extracted from a contract.

**Response**:
```json
{
  "clauses": [
    {
      "clause_id": "uuid",
      "contract_id": "uuid",
      "clause_name": "Payment Terms",
      "description": "Payment due within 30 days of invoice",
      "type": "payment",
      "created_at": "2024-01-15T10:35:00Z"
    }
  ],
  "total": 12
}
```

### Analysis

#### POST /contracts/{contractId}/reanalyze
Trigger a re-analysis of an existing contract.

**Response**:
```json
{
  "message": "Re-analysis started",
  "contract_id": "uuid",
  "status": "processing"
}
```

### User

#### GET /user/profile
Get current user profile.

**Response**:
```json
{
  "user_id": "uuid",
  "email": "user@example.com",
  "full_name": "John Doe",
  "company": "Acme Corp",
  "created_at": "2024-01-01T00:00:00Z",
  "subscription": {
    "plan_type": "pro",
    "contracts_limit": 100,
    "contracts_used": 15
  }
}
```

#### PUT /user/profile
Update user profile.

**Request Body**:
```json
{
  "full_name": "John Doe",
  "company": "New Company Name"
}
```

## Error Responses

All errors follow this format:

```json
{
  "error": "Error message",
  "code": "ERROR_CODE",
  "details": {}
}
```

### Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

### Common Error Codes

- `INVALID_INPUT` - Invalid request data
- `UNAUTHORIZED` - Missing or invalid token
- `CONTRACT_NOT_FOUND` - Contract ID doesn't exist
- `UPLOAD_FAILED` - File upload failed
- `ANALYSIS_FAILED` - Contract analysis failed
- `RATE_LIMIT_EXCEEDED` - Too many requests

## Rate Limiting

- Free tier: 10 requests/minute
- Basic: 60 requests/minute
- Pro: 300 requests/minute
- Enterprise: Unlimited

Rate limit headers:
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1642248000
```

## Webhooks

### Contract Analysis Complete

When a contract analysis completes, a webhook can be sent to your configured URL:

**Payload**:
```json
{
  "event": "contract.analysis.complete",
  "contract_id": "uuid",
  "user_id": "uuid",
  "risk_score": 65,
  "status": "completed",
  "timestamp": "2024-01-15T10:40:00Z"
}
```

## SDK Examples

### JavaScript/TypeScript

```typescript
import axios from 'axios';

const api = axios.create({
  baseURL: 'https://api.contract-ai.example.com',
  headers: {
    'Authorization': `Bearer ${token}`
  }
});

// Upload contract
const formData = new FormData();
formData.append('file', file);
const response = await api.post('/upload', formData);

// Get contracts
const contracts = await api.get('/contracts');
```

### Python

```python
import requests

headers = {'Authorization': f'Bearer {token}'}

# Upload contract
with open('contract.pdf', 'rb') as f:
    files = {'file': f}
    response = requests.post(
        'https://api.contract-ai.example.com/upload',
        files=files,
        headers=headers
    )

# Get contracts
response = requests.get(
    'https://api.contract-ai.example.com/contracts',
    headers=headers
)
```

