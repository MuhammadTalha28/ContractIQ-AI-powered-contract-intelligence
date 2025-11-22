# Deploy Textract Processor with PyPDF2
cd lambdas\textractProcessor

Write-Host "Installing PyPDF2..." -ForegroundColor Yellow
pip install PyPDF2 -t . --quiet

Write-Host "Creating deployment package..." -ForegroundColor Yellow
Compress-Archive -Path * -DestinationPath ..\..\textract-function.zip -Force

Write-Host "Deploying to Lambda..." -ForegroundColor Yellow
aws lambda update-function-code --function-name contract-ai-textract-processor-dev --zip-file fileb://..\..\textract-function.zip

Write-Host "Cleaning up..." -ForegroundColor Yellow
Remove-Item ..\..\textract-function.zip -Force
Remove-Item PyPDF2*,pypdf2* -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "[SUCCESS] Deployed!" -ForegroundColor Green
cd ..\..

