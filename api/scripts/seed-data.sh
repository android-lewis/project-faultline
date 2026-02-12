#!/bin/bash
set -e

TABLE_NAME="${TABLE_NAME:-support-tickets}"
ENDPOINT_ARGS=""

if [ "$1" = "--cloud" ]; then
  echo "Seeding test data into DynamoDB (cloud, table: ${TABLE_NAME})..."
  export AWS_REGION="${AWS_REGION:-eu-west-2}"
else
  echo "Seeding test data into DynamoDB Local (table: ${TABLE_NAME})..."
  export AWS_ACCESS_KEY_ID=dummy
  export AWS_SECRET_ACCESS_KEY=dummy
  export AWS_REGION=eu-west-2
  ENDPOINT_ARGS="--endpoint-url http://localhost:8000"
fi

# Sample tickets for testing
aws dynamodb put-item \
  --table-name "${TABLE_NAME}" \
  --item '{
    "TicketID": {"S": "test-ticket-001"},
    "Description": {"S": "Cannot access my account"},
    "Status": {"S": "open"},
    "Attachments": {"L": []},
    "CreatedAt": {"S": "2026-02-12T00:00:00Z"},
    "UpdatedAt": {"S": "2026-02-12T00:00:00Z"}
  }' \
  ${ENDPOINT_ARGS} \
  --region "${AWS_REGION}"

aws dynamodb put-item \
  --table-name "${TABLE_NAME}" \
  --item '{
    "TicketID": {"S": "test-ticket-002"},
    "Description": {"S": "Feature request: dark mode"},
    "Status": {"S": "in-progress"},
    "Attachments": {"L": [{"S": "https://example.com/screenshot.png"}]},
    "CreatedAt": {"S": "2026-02-11T12:00:00Z"},
    "UpdatedAt": {"S": "2026-02-11T15:30:00Z"}
  }' \
  ${ENDPOINT_ARGS} \
  --region "${AWS_REGION}"

aws dynamodb put-item \
  --table-name "${TABLE_NAME}" \
  --item '{
    "TicketID": {"S": "test-ticket-003"},
    "Description": {"S": "Bug: application crashes on startup"},
    "Status": {"S": "closed"},
    "Attachments": {"L": [{"S": "https://example.com/logs.txt"}, {"S": "https://example.com/crash-dump.log"}]},
    "CreatedAt": {"S": "2026-02-10T09:15:00Z"},
    "UpdatedAt": {"S": "2026-02-11T18:45:00Z"}
  }' \
  ${ENDPOINT_ARGS} \
  --region "${AWS_REGION}"

echo "Seeded 3 test tickets"
