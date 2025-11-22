# Database Setup

## RDS PostgreSQL Setup

### Prerequisites
- AWS RDS PostgreSQL instance (or local PostgreSQL for development)
- Database credentials

### Setup Steps

1. **Create RDS Instance** (via AWS Console or CLI):
```bash
aws rds create-db-instance \
  --db-instance-identifier contract-ai-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password YourPassword \
  --allocated-storage 20 \
  --vpc-security-group-ids sg-xxxxx
```

2. **Connect to Database**:
```bash
psql -h contract-ai-db.xxxxx.us-east-1.rds.amazonaws.com -U admin -d postgres
```

3. **Run Schema**:
```bash
psql -h <host> -U admin -d postgres -f rds_schema.sql
```

### Environment Variables

Set these in your Lambda functions or application:
```
RDS_HOST=contract-ai-db.xxxxx.us-east-1.rds.amazonaws.com
RDS_PORT=5432
RDS_DB=postgres
RDS_USER=admin
RDS_PASSWORD=YourPassword
```

### Connection Pooling

For production, consider using RDS Proxy for connection pooling:
- Reduces connection overhead
- Improves scalability
- Better security with IAM authentication

## DynamoDB Tables

DynamoDB tables are created via CloudFormation. See `infrastructure/cloudformation/main.yaml`.

Tables:
- `contracts`: Contract metadata and status
- `clauses`: Extracted clauses from contracts

