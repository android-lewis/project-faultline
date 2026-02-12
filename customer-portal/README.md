# Customer Portal

A static web application for customers to submit support tickets.

## Overview

This is a single-page static site built with plain HTML, CSS, and Alpine.js. It allows users to submit support tickets with a description and optional file attachments.

## Project Structure

```
customer-portal/
├── index.html              # Main page with ticket submission form
├── css/
│   └── styles.css          # Styling
├── js/
│   ├── config.js           # Environment configuration (gitignored)
│   ├── config.js.example   # Example configuration file
│   └── app.js              # Alpine.js application logic
└── README.md               # This file
```

## Setup

1. **Configure the API endpoint:**
   ```bash
   cp js/config.js.example js/config.js
   ```
   
2. **Edit `js/config.js`** and update the `API_BASE_URL` with your actual API Gateway URL:
   ```javascript
   window.APP_CONFIG = {
       API_BASE_URL: 'https://your-api-id.execute-api.eu-west-2.amazonaws.com'
   };
   ```

## Local Development

Simply open `index.html` in a web browser, or use a local web server:

```bash
# Python 3
python -m http.server 8080

# Node.js (if you have http-server installed)
npx http-server -p 8080
```

Then visit `http://localhost:8080`

## Deployment to S3

### Automated (GitHub Actions)

On every push to `main` that changes files in `customer-portal/`, the workflow at `.github/workflows/customer-portal-deploy.yml` will:

1. Generate `js/config.js` from the `CUSTOMER_PORTAL_API_URL` GitHub Actions variable
2. Sync all files to the `project-faultline-customer-portal` S3 bucket

**Required GitHub configuration:**
- **Secret:** `AWS_ROLE_ARN` — IAM role ARN for OIDC authentication (shared with API deploy)
- **Variable:** `CUSTOMER_PORTAL_API_URL` — API Gateway base URL (e.g., `https://abc123.execute-api.eu-west-2.amazonaws.com`)

### Manual

1. **Update `js/config.js`** with your production API URL

2. **Upload files to S3:**
   ```bash
   aws s3 sync . s3://project-faultline-customer-portal --delete --exclude ".gitignore" --exclude "*.example" --exclude "README.md"
   ```

## API Requirements

The frontend expects the following API endpoints:

### `GET /tickets/upload-url`
Returns a presigned S3 URL for file upload.

**Query Parameters:**
- `filename` (string, required): Name of the file to upload
- `contentType` (string, required): MIME type of the file

**Response:**
```json
{
  "uploadUrl": "https://s3.amazonaws.com/...",
  "key": "attachments/uuid/filename.ext"
}
```

### `POST /tickets`
Creates a new support ticket.

**Request Body:**
```json
{
  "description": "Issue description",
  "attachments": ["key1", "key2"]
}
```

**Response:**
```json
{
  "id": "ticket-uuid"
}
```

### CORS Configuration
The API must allow cross-origin requests from the S3 website origin:
- `Access-Control-Allow-Origin`: S3 website URL or `*` for development
- `Access-Control-Allow-Methods`: `GET, POST, OPTIONS`
- `Access-Control-Allow-Headers`: `Content-Type`

## Features

- ✅ Responsive design (mobile-friendly)
- ✅ Client-side form validation
- ✅ Multi-file upload support
- ✅ Direct upload to S3 via presigned URLs
- ✅ Loading states and error handling
- ✅ Success confirmation with ticket ID
- ✅ No build step required

## Technologies

- **Alpine.js 3.x** (loaded via CDN)
- **HTML5**
- **CSS3** (responsive, no framework)
- **JavaScript ES6+**

## Browser Support

Modern browsers with ES6 support (Chrome, Firefox, Safari, Edge).
