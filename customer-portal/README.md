# Customer Portal

Preact + Vite single-page application for customer support ticket submission with Cognito authentication.

## Features

- **Authentication**: Cognito Hosted UI with OAuth 2.0 Authorization Code + PKCE flow
- **Routing**: Client-side routing via `preact-iso`
- **Auth Management**: `oidc-client-ts` for token handling, auto-refresh, and session storage
- **API Integration**: Authenticated requests to the Lambda API with JWT bearer tokens
- **Ticket Submission**: Create tickets with optional file attachments uploaded via presigned S3 URLs
- **Ticket List**: View and refresh your existing tickets on the home page
- **Styling**: Tailwind CSS v4 via Vite plugin

## Prerequisites

- Node.js 20+
- pnpm 10+
- AWS Cognito user pool (configured via Terraform in `infra/`)

## Local Development Setup

### 1. Configure environment variables

Copy `.env.example` to `.env.local` and populate with your Cognito values:

```bash
cp .env.example .env.local
```

Get the required values from Terraform outputs:

```bash
cd ../infra
terraform output
```

Update `.env.local`:

```env
VITE_COGNITO_AUTHORITY=https://cognito-idp.eu-west-2.amazonaws.com/{cognito_user_pool_id}
VITE_COGNITO_CLIENT_ID={cognito_customer_portal_client_id}
VITE_COGNITO_DOMAIN={cognito_user_pool_domain}.auth.eu-west-2.amazoncognito.com
VITE_COGNITO_REDIRECT_URI=http://localhost:5173/callback
VITE_COGNITO_POST_LOGOUT_REDIRECT_URI=http://localhost:5173
VITE_API_URL=http://localhost:3000
```

### 2. Install dependencies

```bash
pnpm install
```

### 3. Run development server

```bash
pnpm run dev
```

App will be available at `http://localhost:5173`

### 4. Run the API locally

In a separate terminal:

```bash
cd ../api
make local
```

API will be available at `http://localhost:3000`

## Build for Production

```bash
pnpm run build
```

Output is in `dist/` directory.

## Deployment

Deployment is automated via GitHub Actions (`.github/workflows/customer-portal-deploy.yml`).

On push to `main` (with changes in `customer-portal/**`):
1. Builds the app with Vite
2. Injects environment variables from GitHub vars
3. Syncs `dist/` to S3 bucket

### Required GitHub Variables

Set these in your repository settings → Secrets and variables → Actions → Variables:

- `VITE_COGNITO_AUTHORITY`
- `VITE_COGNITO_CLIENT_ID`
- `VITE_COGNITO_DOMAIN`
- `VITE_COGNITO_REDIRECT_URI` (production S3 URL + `/callback`)
- `VITE_COGNITO_POST_LOGOUT_REDIRECT_URI` (production S3 URL)
- `VITE_API_URL` (API Gateway URL)

## Project Structure

```
customer-portal/
├── src/
│   ├── api/
│   │   └── client.ts              # Authenticated API client
│   ├── auth/
│   │   ├── config.ts              # OIDC configuration
│   │   ├── auth-service.ts        # Auth service wrapper
│   │   └── AuthGuard.tsx          # Protected route guard
│   ├── components/
│   │   ├── Header.tsx             # Nav with user info + logout
│   │   ├── TicketForm.tsx         # Submit ticket + attachment upload
│   │   └── TicketList.tsx         # User ticket list
│   ├── pages/
│   │   ├── Home/
│   │   ├── Callback/              # OAuth callback handler
│   │   └── _404.tsx
│   ├── index.tsx                  # App entry + router
│   ├── style.css
│   └── env.d.ts                   # TypeScript env declarations
├── .env.example                   # Example environment file
├── .env.local                     # Local dev config (gitignored)
├── package.json
├── vite.config.ts
└── tsconfig.json
```

## Authentication Flow

1. User visits protected route (e.g., `/`)
2. `AuthGuard` checks if authenticated
3. If not, redirects to Cognito Hosted UI
4. User logs in with credentials
5. Cognito redirects back to `/callback` with auth code
6. `Callback` page exchanges code for tokens
7. Tokens stored in session storage
8. User redirected to home page
9. All API requests include `Authorization: Bearer {access_token}` header

## Test Users

See `infra/modules/cognito/main.tf` for test user credentials.
