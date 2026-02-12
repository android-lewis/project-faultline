# Internal Portal

The internal portal is a static website for managing customer support tickets. It provides a list view of all tickets with status filtering and detailed views for updating ticket status.

## Features

- **Ticket List**: View all tickets with status filtering (All, Open, In Progress, Closed)
- **Ticket Details**: View full ticket information including description, attachments, and timestamps
- **Status Management**: Update ticket status (open → in-progress → closed)
- **Real-time Updates**: Changes are immediately reflected in the interface

## Technology Stack

- **Frontend**: Static HTML + Alpine.js 3.x
- **Styling**: Pure CSS with responsive design
- **Hosting**: AWS S3 static website hosting
- **API**: Same API as customer portal

## Local Development

1. **Copy the example config**:
   ```bash
   cp js/config.js.example js/config.js
   ```

2. **Update the API URL** in `js/config.js`:
   ```javascript
   window.APP_CONFIG = {
       API_BASE_URL: 'https://your-api-url.execute-api.eu-west-2.amazonaws.com'
   };
   ```

3. **Serve locally**:
   ```bash
   # Using Python
   python3 -m http.server 8080
   
   # Or using Node.js
   npx http-server -p 8080
   ```

4. **Open in browser**: http://localhost:8080

## Deployment

Deployment is automated via GitHub Actions. Pushes to `main` that affect `internal-portal/**` trigger a deployment to S3.

The workflow:
1. Generates `js/config.js` from the `INTERNAL_PORTAL_API_URL` GitHub variable
2. Syncs all files to the S3 bucket: `project-faultline-internal-portal`

## Pages

### index.html (Ticket List)
- Displays all tickets in a card grid
- Filter tabs for status (All, Open, In Progress, Closed)
- Click any ticket to view details

### ticket.html (Ticket Detail)
- Shows full ticket information
- Update ticket status via dropdown + button
- Lists attachments (if any)
- Back link to ticket list

## API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/tickets` | GET | Fetch all tickets |
| `/tickets/{id}` | GET | Fetch single ticket |
| `/tickets/{id}/status` | PATCH | Update ticket status |

## Architecture

This portal mirrors the customer portal's architecture:
- No build step required (Alpine.js loaded from CDN)
- Config file is gitignored and generated at deploy time
- CORS enabled on API for cross-origin requests
- Fully static — no server-side code
