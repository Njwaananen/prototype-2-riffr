# Riffr – Prototype 3 (Supabase + Lambda API + Amplify Frontend)

Riffr is a collaboration-matching app for music creators. Producers, vocalists,
engineers, and songwriters can discover each other, browse profiles, and start
conversations based on shared genres and roles.

This prototype demonstrates:

- A Supabase-backed Postgres database (profiles + seed data)
- A Node/Express API deployed to AWS Lambda via Serverless
- A static frontend deployed to AWS Amplify
- Multiple pages that load real data from the deployed API

---

## Live URLs

Frontend (Amplify)  
https://main.d2eqw1u0trx2o8.amplifyapp.com

API base (Lambda / API Gateway)  
https://swx5z75dob.execute-api.us-west-2.amazonaws.com/api

Example health check (terminal):

    curl "https://swx5z75dob.execute-api.us-west-2.amazonaws.com/api/health"
    # → { "ok": true }

---

## Tech stack

- Database: Supabase (Postgres)
- Backend: Node 18, Express, Supabase JS client
- Deployment: Serverless Framework → AWS Lambda + HTTP API
- Frontend: Static HTML/CSS/JS, deployed via AWS Amplify
- Auth (prototype): simple shared API key (x-api-key) for local dev

---

## Data model (high level)

The prototype focuses on a single core entity:

- profiles  
  - profile_id (UUID)  
  - display_name  
  - headline  
  - bio  
  - location_text  
  - primary_role (vocalist, producer, engineer, songwriter, etc.)  
  - genres (comma-separated text for this prototype)  
  - other metadata used by the UI  

Seed data includes at least three demo users (for example, Lana R., Marco B., Ayana).

Database schema and seed scripts live in:

- db/01_schema.sql  
- db/02_seed.sql  
- db/03_policies.sql (optional RLS / permissions)

Running 01_schema.sql then 02_seed.sql on a clean Supabase project should
recreate the tables and demo rows.

---

## API

All routes are relative to the API base:

    https://swx5z75dob.execute-api.us-west-2.amazonaws.com/api

Core routes:

- GET /health  
  Simple health check. Returns { "ok": true } when the Lambda is healthy.

- GET /profiles  
  Returns all demo profiles from Supabase.

- GET /profiles/search/by-genre?genre=<name>  
  Returns the subset of profiles whose "genres" field matches the requested
  genre (for example, hip-hop, metal).

Note: In this prototype, writes (creating/saving profiles or messages) are not
wired all the way through to the database. Forms update the UI only.

---

## Local development

You can still run the API and client locally without hitting AWS.

### Prereqs

- Node 18+
- Supabase project with the Riffr schema and seed data applied
- Supabase project URL and service role key

### 1. Configure environment

From the repo root:

    cd api
    cp .env.example .env

Fill in .env with your project values:

    SUPABASE_URL=https://<your-project>.supabase.co
    SUPABASE_SERVICE_ROLE_KEY=<your-service-role-key>
    API_KEY=riffr-dev-secret-123
    PORT=3000

IMPORTANT: never commit real keys. .env is listed in .gitignore.

### 2. Run the API locally

    cd api
    npm install
    npm run dev      # or: node src/index.js

The local API will listen on:

    http://localhost:3000/api

Test it:

    curl "http://localhost:3000/api/health"
    curl "http://localhost:3000/api/profiles"
    curl "http://localhost:3000/api/profiles/search/by-genre?genre=hip-hop"

If the project uses a simple API key check, include:

    -H "x-api-key: riffr-dev-secret-123"

### 3. Run the client locally

From the repo root:

    cd client
    npx serve .

The dev server will print a URL such as http://localhost:4173 (or similar).
Open it in a browser to view the app.

For local testing, you can point the frontend to:

    const API_BASE = "http://localhost:3000/api";

In the deployed version, API_BASE is set to the Lambda URL.

---

## Deployed architecture

Backend:

- The api/ folder is deployed via Serverless Framework as a single Lambda
  function.
- Service: riffr-api  
- Region: us-west-2  
- Stage: dev  
- Endpoint (catch-all):  
  https://swx5z75dob.execute-api.us-west-2.amazonaws.com/{proxy+}

Environment variables (Supabase URL, service-role key, API key) are passed in
from the Lambda configuration / Serverless.

Frontend:

- The client/ folder is connected to AWS Amplify as a static site.
- App: prototype-2-riffr  
- Prod branch: main  
- Domain: https://main.d2eqw1u0trx2o8.amplifyapp.com  

Whenever changes are pushed to main on GitHub, Amplify rebuilds and redeploys
the frontend automatically.

---

## How to demo the prototype

When grading or demoing, use the deployed Amplify URL.

1. Discover (index.html)  
   - Shows a hero banner and two dynamic lists:  
     - "Based on your saves" – populated from /profiles (first 1–2 profiles).  
     - "Recently active" – populated from all profiles.  
   - Data is loaded from the deployed API at page load.

2. Browse (browse.html)  
   - Calls GET /profiles to show all demo matches.  
   - Genre filter uses GET /profiles/search/by-genre?genre=<name>.  
   - Live Supabase data is rendered as "creator cards."

3. My Profile (profile.html)  
   - On load, fetches GET /profiles and treats the first record as "you."  
   - Pre-fills display name, headline, bio, location, role, and genres.  
   - The "Save profile" button validates the form and shows a confirmation
     message. For this prototype, save is local-only (no DB write).

4. Messages (messages.html)  
   - UI for an inbox and message thread.  
   - In this prototype, conversations and replies are managed client-side only
     (no database writes yet), but the screen demonstrates the planned
     messaging layout and flow.

Navigation is consistent across the top/bottom nav bars, so all main screens
are reachable from any other screen.

---

## Troubleshooting

- If profiles do not load:
  - Check that the Lambda API URL in the frontend matches the deployed endpoint.
  - Use curl <API_BASE>/api/health to confirm the API is up.
  - Confirm Supabase service role key and URL are correct in the Lambda env vars.

---

## Known limitations / future work

- No authenticated user accounts yet; all data is demo data.
- Profile edits and messages do not persist to Supabase.
- API does not implement pagination or advanced search.
- Genres are stored as a single text field instead of a normalized table.
- Error handling is minimal (simple on-screen messages).

Future iterations would:

- Persist profile updates and messages through the API.
- Normalize genres and add follower / "save" relationships.
- Add more robust filtering and recommendations.

---

## Repo structure (high-level)

    api/          # Node/Express API, Serverless config, Supabase client
      src/
      serverless.yml
      .env.example
    client/       # Static frontend (HTML/CSS/JS)
    db/           # SQL schema + seed scripts for Supabase
    tests/        # HTTP smoke tests, curl examples
    README.md     # This file
    Deployment.md # Deployment resource IDs, commands, rollback notes
