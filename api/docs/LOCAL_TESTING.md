# Local Development & Testing Guide

## Overview

This guide covers local development and testing of the Faultline API using **DynamoDB Local** (a free, Docker-based version of DynamoDB) and **SAM Local** for running the Lambda function locally.

## Prerequisites

- Docker Desktop installed with WSL2 integration enabled
- AWS SAM CLI installed
- AWS CLI installed
- Go 1.26+

## Quick Start

### 1. Start Local Environment

```bash
# Start DynamoDB Local, create table, and seed test data
make local-setup
```

This will:
- Start DynamoDB Local on `http://localhost:8000`
- Start DynamoDB Admin UI on `http://localhost:8001`
- Create the `support-tickets` table
- Seed 3 test tickets

### 2. Start the API

In a new terminal:

```bash
# Start SAM local API with DynamoDB Local integration
make local
```

The API will be available at `http://localhost:3000`

**Note**: First run will download Docker images (~500MB), which takes 2-5 minutes.

### 3. Test the API

```bash
# Health check
curl http://localhost:3000/health

# List all tickets (includes seeded data)
curl http://localhost:3000/tickets

# Get a specific ticket
curl http://localhost:3000/tickets/test-ticket-001

# Create a new ticket
curl -X POST http://localhost:3000/tickets \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Test ticket from local",
    "attachments": []
  }'
```

## Available Commands

See `make help` for full list. Key commands:

- `make local-setup` - Start DynamoDB Local + init + seed (one command)
- `make local` - Start SAM local API
- `make test-all` - Run all tests
- `make local-clean` - Clean up environment

## DynamoDB Local

DynamoDB Local is 100% free and runs in Docker. Access it at:
- **API**: http://localhost:8000
- **Web UI**: http://localhost:8001

## Troubleshooting

### Port Already in Use
```bash
lsof -ti:8000 | xargs kill -9
```

### DynamoDB Table Not Found
```bash
make dynamodb-init
```

### SAM Local Slow First Start
Normal - downloading Docker images (~500MB). Only happens once.

For detailed troubleshooting, see full documentation.
