#!/bin/bash
set -e

echo "Initializing DynamoDB Local table..."

# Set dummy AWS credentials for local DynamoDB
export AWS_ACCESS_KEY_ID=dummy
export AWS_SECRET_ACCESS_KEY=dummy
export AWS_REGION=eu-west-2

# Wait for DynamoDB Local to be ready
echo "Waiting for DynamoDB Local to be ready..."
for i in {1..30}; do
  if aws dynamodb list-tables --endpoint-url http://localhost:8000 --region eu-west-2 --output text 2>/dev/null; then
    echo "DynamoDB Local is ready"
    break
  fi
  sleep 1
done

# Check if table already exists
if aws dynamodb describe-table \
  --table-name support-tickets \
  --endpoint-url http://localhost:8000 \
  --region eu-west-2 \
  --output text 2>/dev/null; then
  echo "Table 'support-tickets' already exists"
  exit 0
fi

# Create the table
echo "Creating table 'support-tickets'..."
aws dynamodb create-table \
  --table-name support-tickets \
  --attribute-definitions \
    AttributeName=TicketID,AttributeType=S \
  --key-schema \
    AttributeName=TicketID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url http://localhost:8000 \
  --region eu-west-2 \
  --output text

echo "✓ Table 'support-tickets' created successfully"

# Wait for table to be active
aws dynamodb wait table-exists \
  --table-name support-tickets \
  --endpoint-url http://localhost:8000 \
  --region eu-west-2

echo "Table is ready"
