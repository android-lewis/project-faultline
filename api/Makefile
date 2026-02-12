.PHONY: build clean deploy test validate sam-build sam-deploy sam-local \
        dynamodb-up dynamodb-down dynamodb-init dynamodb-seed dynamodb-seed-cloud local-setup local-clean \
        test-unit test-integration test-all

# ============================================================================
# Local Development with DynamoDB Local
# ============================================================================

# Start DynamoDB Local and admin UI
dynamodb-up:
	docker compose up -d
	@echo "✓ DynamoDB Local running at http://localhost:8000"
	@echo "✓ DynamoDB Admin UI at http://localhost:8001"

# Stop DynamoDB Local
dynamodb-down:
	docker compose down

# Initialize DynamoDB Local table
dynamodb-init:
	@./scripts/init-dynamodb.sh

# Seed test data
dynamodb-seed:
	@./scripts/seed-data.sh

# Seed test data into cloud DynamoDB
# Usage: make dynamodb-seed-cloud [TABLE_NAME=my-table]
dynamodb-seed-cloud:
	@./scripts/seed-data.sh --cloud

# Full local setup (start + init + seed)
local-setup: dynamodb-up
	@sleep 3
	@./scripts/init-dynamodb.sh
	@./scripts/seed-data.sh
	@echo ""
	@echo "✓ Local environment ready!"
	@echo "  - DynamoDB Local: http://localhost:8000"
	@echo "  - Admin UI: http://localhost:8001"
	@echo ""
	@echo "Next: Run 'make sam-local-dynamo' to start the API"

# Clean local environment
local-clean: dynamodb-down
	docker volume rm api_dynamodb-data 2>/dev/null || true
	@echo "✓ Local environment cleaned"

# ============================================================================
# SAM Build & Deploy
# ============================================================================

# SAM build (recommended)
sam-build:
	sam build

# Validate SAM template
validate:
	sam validate --lint

# Build using SAM with Go
build: sam-build

# Clean build artifacts
clean:
	rm -f bootstrap deployment.zip
	rm -rf .aws-sam

# Deploy using SAM (requires parameters)
# Usage: make sam-deploy PARAMS="TicketsBucketName=my-bucket LambdaS3PolicyArn=arn:... DynamoDBTableName=support-tickets"
sam-deploy:
	@if [ -z "$(PARAMS)" ]; then \
		echo "Error: PARAMS variable required"; \
		echo "Usage: make sam-deploy PARAMS=\""; \
		exit 1; \
	fi
	sam deploy --parameter-overrides TicketsBucketName=support-tickets

# Deploy using SAM (main target)
deploy: sam-build sam-deploy

# ============================================================================
# Local API Testing
# ============================================================================

# Local development with SAM (requires DynamoDB Local running)
sam-local-dynamo: sam-build
	@echo "Starting SAM local API with DynamoDB Local..."
	@echo "Note: Set AWS_ENDPOINT_URL in your Lambda code for local DynamoDB"
	AWS_ACCESS_KEY_ID=dummy \
	AWS_SECRET_ACCESS_KEY=dummy \
	sam local start-api --env-vars env.json --docker-network api_faultline-network

# Standard SAM local (without DynamoDB Local integration)
sam-local: sam-build
	sam local start-api

# Alias for local with DynamoDB
local: sam-local-dynamo

# ============================================================================
# Testing
# ============================================================================

# Run unit tests (fast, uses mocks)
test-unit:
	go test -v -short ./internal/handlers/...

# Run integration tests (requires DynamoDB Local)
test-integration:
	@if ! docker ps | grep -q faultline-dynamodb-local; then \
		echo "Error: DynamoDB Local not running. Run 'make local-setup' first"; \
		exit 1; \
	fi
	AWS_ACCESS_KEY_ID=dummy \
	AWS_SECRET_ACCESS_KEY=dummy \
	AWS_ENDPOINT_URL=http://localhost:8000 \
	go test -v ./internal/repository/...

# Run all tests
test-all: test-unit test-integration

# Run tests (default: all tests)
test:
	go test -v ./...

# Test coverage
test-coverage:
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "✓ Coverage report generated: coverage.html"

# Format code
fmt:
	go fmt ./...

# Run linter
lint:
	go vet ./...

# Install dependencies
deps:
	go mod download
	go mod tidy

# ============================================================================
# Help
# ============================================================================

# Display help
help:
	@echo "Faultline API - Available Commands"
	@echo ""
	@echo "Local Development:"
	@echo "  make local-setup        - Start DynamoDB Local + init table + seed data"
	@echo "  make dynamodb-up        - Start DynamoDB Local containers"
	@echo "  make dynamodb-down      - Stop DynamoDB Local"
	@echo "  make dynamodb-init      - Initialize DynamoDB table"
	@echo "  make dynamodb-seed      - Seed test data (local)"
	@echo "  make dynamodb-seed-cloud - Seed test data (cloud DynamoDB)"
	@echo "  make local              - Start SAM local API with DynamoDB Local"
	@echo "  make sam-local-dynamo   - Same as 'make local'"
	@echo "  make local-clean        - Stop and clean local environment"
	@echo ""
	@echo "Testing:"
	@echo "  make test-unit          - Run unit tests (fast)"
	@echo "  make test-integration   - Run integration tests (requires DynamoDB Local)"
	@echo "  make test-all           - Run all tests"
	@echo "  make test-coverage      - Generate test coverage report"
	@echo ""
	@echo "Build & Deploy:"
	@echo "  make sam-build          - Build with SAM CLI"
	@echo "  make validate           - Validate SAM template"
	@echo "  make sam-deploy         - Deploy with SAM (requires PARAMS)"
	@echo "  make deploy             - Build and deploy with SAM"
	@echo ""
	@echo "Code Quality:"
	@echo "  make fmt                - Format Go code"
	@echo "  make lint               - Run Go linter"
	@echo "  make deps               - Install dependencies"
	@echo ""
	@echo "Quick Start:"
	@echo "  1. make local-setup     # Start DynamoDB Local"
	@echo "  2. make local           # Start API (in another terminal)"
	@echo "  3. curl http://localhost:3000/health"
