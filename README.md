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

## API Deployment (Lambda + API Gateway)

- The Express app in the api/ directory is wrapped with serverless-http
  (lambda entry file) so it can run as an AWS Lambda function behind an HTTP
  API Gateway.
- Serverless Framework configuration lives in api/serverless.yml and defines:
  - service: riffr-api
  - stage: dev
  - region: us-west-2
  - a single function (riffr-api-dev-app) that handles all HTTP routes.
- Supabase configuration (SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, API_KEY) is
  loaded from Lambda environment variables in AWS and from a local .env file
  for development. AWS Secrets Manager is not used in this prototype; env vars
  are sufficient for the class deployment.
- The API is deployed with Serverless using:

      cd api
      npx serverless deploy

  (or equivalently npm run deploy if scripted in package.json).
- The deployment exposes an HTTP API at:

      https://swx5z75dob.execute-api.us-west-2.amazonaws.com/api

- The frontend is configured to call this API base URL, and the deployed
  Amplify site has been verified to load live data via /health, /profiles,
  and /profiles/search/by-genre.

---

## Deployment, rollback & backups

### Frontend (Amplify)

- Amplify app: `prototype-2-riffr` (region: us-east-2)
- Prod branch: `main`
- URL: https://main.d2eqw1u0trx2o8.amplifyapp.com

**Deploy:** push to `main` on GitHub:

    git add .
    git commit -m "Update Riffr prototype"
    git push origin main

Amplify watches the repo, runs the static build for `client/`, and deploys.

**Rollback (frontend):**

- In the Amplify console, open **prototype-2-riffr → Deployments**.
- Find a previous known-good build.
- Click **“Redeploy this version”** to roll back without changing code.

### Backend (Serverless / Lambda / API Gateway)

- Service: `riffr-api`
- Stage: `dev`
- Region: `us-west-2`
- Lambda function: `riffr-api-dev-app`
- HTTP API base URL: https://swx5z75dob.execute-api.us-west-2.amazonaws.com/api

**Deploy (backend):**

    cd api
    npx serverless deploy

**Rollback (backend):**

1. List past deployments:

       cd api
       npx serverless deploy list

2. Copy the desired `timestamp` from the list.

3. Roll back:

       npx serverless rollback --timestamp <TIMESTAMP>

4. Verify after rollback:

       export API_BASE="https://swx5z75dob.execute-api.us-west-2.amazonaws.com/api"
       curl "$API_BASE/health"

### Supabase backups

- Database is hosted on Supabase (Postgres) in the Riffr prototype project.
- Supabase provides automatic backups and point-in-time recovery.
- Backup schedule can be viewed under **Project → Settings → Backups** in the
  Supabase dashboard.
- For this prototype, the default daily backup schedule is sufficient; a
  production deployment would document a stricter backup and restore policy.

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

## Monitoring & Security

Logging and monitoring:

- Lambda log group `/aws/lambda/riffr-api-dev-app` is configured in CloudWatch
  with log retention set to 30 days.
- Amplify access logs are available for the production frontend domain
  (main.d2eqw1u0trx2o8.amplifyapp.com) for basic request auditing.

Alerts:

- A CloudWatch alarm on the `Errors` metric for `riffr-api-dev-app` triggers
  when there are 10 or more Lambda errors in a 5-minute window. The alarm
  notifies an SNS topic subscribed to the developer’s email.
- Build and deployment status is monitored via the Amplify console and GitHub
  notifications for pushes to the main branch.

Supabase configuration:

- Supabase Auth URL configuration has been set to match the deployed frontend:
  - Site URL is configured as https://main.d2eqw1u0trx2o8.amplifyapp.com.
  - Redirect URLs include the Amplify domain for future auth flows.
- Row-level security (RLS) is not enforced on the demo `profiles` table so the
  prototype can read all demo rows without authentication. A production version
  would enable RLS and scope access per authenticated user.
- Supabase email templates for magic-link / OTP flows are left at their
  defaults because authentication is out of scope for this prototype. They
  would be customized with Riffr branding and subject lines in a future
  auth-enabled version.

Secrets and configuration:

- `.env` files are ignored via `.gitignore`; only `api/.env.example` is tracked
  in Git, and it contains no real secrets.
- Supabase URL, Supabase service role key, and API key are stored only in local
  `.env` files and Lambda/Amplify environment variables, not in source control.

CORS and access control:

- For this prototype, CORS is configured permissively to simplify development.
  In a production deployment, CORS would be restricted to the Amplify domain
  and any other trusted origins.

IAM and least privilege:

- A dedicated IAM user (`riff-api-deployer`) is used for Serverless
  deployments. This user currently has the AWS-managed `AdministratorAccess`
  policy attached, which is broad but acceptable for a classroom prototype.
- In a production setting, this deployer would be restricted to a custom
  least-privilege policy that only permits the specific services required
  (Lambda, API Gateway, CloudWatch, Amplify, and a secrets/parameter store).

---

## Known limitations / future work

- No authenticated user accounts yet; all data is demo data.
- Profile edits and messages do not persist to Supabase.
- API does not implement pagination or advanced search.
- Genres are stored as a single text field instead of a normalized table.
- Error handling is minimal (simple on-screen messages).

Future iterations would:

- Add real auth and per-user profiles, using RLS and stricter CORS.
- Persist profile updates and messages through the API.
- Normalize genres and add follower / "save" relationships.
- Add more robust filtering and recommendations.
- Tighten IAM policies and CORS configuration for least-privilege, locked-down
  production access.
- Customize Supabase auth email templates and complete the end-to-end signup /
  login flow.

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
