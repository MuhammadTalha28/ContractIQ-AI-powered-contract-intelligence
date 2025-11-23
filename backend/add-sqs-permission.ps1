# Add SQS permissions to Lambda role
$policyJson = @'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:GetQueueAttributes",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage"
      ],
      "Resource": "arn:aws:sqs:us-east-1:YOUR_AWS_ACCOUNT_ID:contract-ai-processing-dev"
    }
  ]
}
'@

# Save to file with UTF-8 encoding (no BOM)
[System.IO.File]::WriteAllText("$PWD\sqs-policy.json", $policyJson, [System.Text.UTF8Encoding]::new($false))

aws iam put-role-policy --role-name contract-ai-lambda-role-dev --policy-name SQSPermissions --policy-document file://sqs-policy.json

if ($LASTEXITCODE -eq 0) {
    Write-Host "SQS permissions added!" -ForegroundColor Green
    Remove-Item sqs-policy.json
} else {
    Write-Host "Error adding permissions. Check sqs-policy.json file." -ForegroundColor Red
}
