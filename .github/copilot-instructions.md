# Copilot Instructions for Project Faultline

## Architecture

This is a serverless support ticket system on AWS (eu-west-2) with a monorepo structure:

- **`api/`** — Go 1.26 Lambda function using Chi router adapted for Lambda via `aws-lambda-go-api-proxy`. Single Lambda serves all API routes through API Gateway (HTTP API). Repository pattern with a `TicketRepository` interface backed by DynamoDB.
- **`customer-portal/`** — Static HTML/CSS site using Alpine.js (CDN, no build step). Deployed directly to S3 website hosting. Uploads files to S3 via presigned URLs (no backend intermediary).
- **`internal-portal/`** — Planned admin portal (not yet implemented).
- **`common/`** — Shared code (not yet implemented).
- **`infra/`** — Terraform with modules (`s3`, `dynamodb`, `iam`, `cloudwatch`). Remote state in S3 with DynamoDB locking.

### API Endpoints

| Path | Method | Purpose |
|------|--------|---------|
| `/health` | GET | Health check |
| `/tickets` | POST | Create ticket |
| `/tickets` | GET | List tickets |
| `/tickets/{id}` | GET | Get ticket by ID |
| `/tickets/upload-url` | GET | Get presigned S3 upload URL |

### Key Data Model

The `Ticket` struct uses dual JSON/DynamoDB tags. The DynamoDB partition key is `TicketID` (maps to `id` in JSON). Statuses are `open`, `closed`, `in-progress`.

## Build, Test, and Lint Commands

All commands run from the `api/` directory:

```bash
# Local development
make local-setup        # Start DynamoDB Local + init table + seed data
make local              # Run API locally via SAM CLI (port 3000)

# Testing
make test-unit          # Unit tests (mocked, no infra needed)
make test-integration   # Integration tests (requires DynamoDB Local)
make test-all           # Run all tests
make test-coverage      # Generate HTML coverage report

# Single test (Go standard):
cd api && go test -run TestFunctionName ./internal/handlers/...

# Code quality
make fmt                # Format Go code
make lint               # Run go vet

# Build & deploy
make sam-build          # Build with SAM CLI
make validate           # Validate SAM template
make deploy             # Build + deploy to AWS
```

The customer portal has no build step — edit HTML/CSS/JS directly.

## CI/CD

Both workflows use GitHub Actions OIDC for keyless AWS authentication:

- **API** (`api-deploy.yml`): Triggered by pushes to `main` affecting `api/**`. Runs lint → test → SAM build → SAM deploy.
- **Customer Portal** (`customer-portal-deploy.yml`): Triggered by pushes to `main` affecting `customer-portal/**`. Generates `config.js` from GitHub variable `CUSTOMER_PORTAL_API_URL`, then syncs to S3.

## Conventions

### Go API patterns

- **Router setup**: Chi router with Logger, Recoverer, RequestID middleware and a `Content-Type: application/json` header set in `main.go`.
- **Error handling**: Use `respondWithError(w, statusCode, message)` and `respondWithJSON(w, statusCode, payload)` helpers in handlers. Wrap errors with `fmt.Errorf("context: %w", err)` for error chain visibility. Match custom errors with `errors.Is()`.
- **Repository pattern**: All DynamoDB access goes through the `TicketRepository` interface. Handlers receive the repository as a dependency, enabling mock-based unit testing.
- **IDs**: Generated with `google/uuid`. S3 attachment keys use format `attachments/{uuid}/{filename}`.
- **Timestamps**: Always UTC via `time.Now().UTC()`.
- **Local dev**: The API detects `DYNAMODB_ENDPOINT_URL` to switch to a local DynamoDB endpoint with dummy credentials.

### Customer Portal patterns

- **Alpine.js**: All interactivity is managed via Alpine.js `x-data` components in `app.js`. No framework CLI or bundler.
- **Config**: `config.js` is gitignored and generated at deploy time. For local dev, copy from the example or create manually with the API URL.

### Infrastructure

- **Terraform modules**: Each AWS service type has its own module under `infra/modules/`. Reference existing module patterns when adding resources.
- **OIDC**: No AWS access keys are stored. GitHub Actions authenticates via OIDC provider configured in the `iam` module.
