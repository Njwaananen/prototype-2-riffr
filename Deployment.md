# Riffr Deployment Notes

This document records the key deployment resources, commands, and rollback /
backup notes for the Riffr Prototype 3 app.

---

## Core resources

- **Frontend (Amplify app)**  
  - App name: prototype-2-riffr  
  - Region: us-east-2  
  - Prod branch: main  
  - Public URL: https://main.d2eqw1u0trx2o8.amplifyapp.com

- **Backend API (Lambda + API Gateway via Serverless)**  
  - Service: riffr-api  
  - Stage: dev  
  - Region: us-west-2  
  - Lambda function name: riffr-api-dev-app  
  - API Gateway ID: swx5z75dob  
  - HTTP API base URL: https://swx5z75dob.execute-api.us-west-2.amazonaws.com/api

- **Database (Supabase)**  
  - Project name: <FILL IN YOUR SUPABASE PROJECT NAME HERE>  
  - Backend: PostgreSQL managed by Supabase  
  - Core table for this prototype: profiles

---

## Frontend (AWS Amplify)

- App name: prototype-2-riffr  
- Prod branch: main  
- Region: us-east-2  
- URL: https://main.d2eqw1u0trx2o8.amplifyapp.com

### Deployment

Deploying the frontend is done by pushing to the main branch:

    git add .
    git commit -m "Update Riffr frontend"
    git push origin main

Amplify watches the GitHub repo, runs the static build for the client/ folder,
and deploys the new version.

### Rollback (frontend)

To roll back the frontend to a previous build:

1. Open the AWS Amplify console.
2. Select the app: prototype-2-riffr.
3. Go to the Deployments (or Build history) view for the main branch.
4. Find a previous known-good build.
5. Click “Redeploy this version” to restore that build without changing code.

---

## Backend API (Lambda + API Gateway via Serverless)

- Service: riffr-api  
- Stage: dev  
- Region: us-west-2  
- Lambda function name: riffr-api-dev-app  
- CloudWatch log group: /aws/lambda/riffr-api-dev-app (retention set to 30 days)  
- API Gateway ID: swx5z75dob  
- HTTP API base URL: https://swx5z75dob.execute-api.us-west-2.amazonaws.com/api

The Express app in the api/ directory is wrapped with serverless-http so it can
run as an AWS Lambda function behind an HTTP API Gateway.

### Deployment commands (backend)

From the repo root:

    cd api
    npm install          # only needed the first time
    npx serverless deploy

This packages the current API code, updates the riffr-api-dev-app Lambda
function, and updates the HTTP API Gateway routes.

To verify after deployment:

    export API_BASE="https://swx5z75dob.execute-api.us-west-2.amazonaws.com/api"
    curl "$API_BASE/health"

You should see a JSON response like { "ok": true }.

### Rollback (backend)

Serverless keeps a deployment history that can be rolled back by timestamp.

From the api/ folder:

1. List recent deployments:

       npx serverless deploy list

2. Copy the desired timestamp from the list (a known-good deployment).

3. Roll back to that deployment:

       npx serverless rollback --timestamp <TIMESTAMP>

4. Verify the rolled-back version is healthy:

       export API_BASE="https://swx5z75dob.execute-api.us-west-2.amazonaws.com/api"
       curl "$API_BASE/health"

---

## Supabase

- Project name: <FILL IN YOUR SUPABASE PROJECT NAME HERE>  
- Project URL: https://<your-project>.supabase.co  
- Core table: profiles

### Schema & seed scripts

The schema and seed data for the prototype live in the db/ folder:

- db/01_schema.sql  
- db/02_seed.sql  

To recreate the demo data on a clean Supabase project:

1. In the Supabase dashboard, open the SQL editor.
2. Run 01_schema.sql to create tables, primary keys, and constraints.
3. Run 02_seed.sql to insert demo profiles.

Row-level security (RLS) is disabled on profiles in this prototype so the
anonymous demo can read all profiles through the API. A production deployment
would enable RLS and restrict access by user.

### Backups

Supabase provides automatic backups and point-in-time recovery.

- In the Supabase dashboard, open **Project → Settings → Backups**.
- Confirm that automatic daily backups are enabled for the project.
- For this classroom prototype, the default daily schedule is sufficient.
- In a production deployment, restore procedures and RPO/RTO would be
  documented in more detail.

---

## Secrets & environment configuration

The project avoids storing secrets in source control:

- Supabase URL, Supabase service-role key, and the API key are stored in:
  - local .env files (ignored by git) for development
  - Lambda environment variables for the deployed API
- The frontend (Amplify) does not need Supabase keys because it never calls
  Supabase directly; all database access is handled by the backend API.

Example local environment (api/.env):

    SUPABASE_URL=https://<your-project>.supabase.co
    SUPABASE_SERVICE_ROLE_KEY=<your-service-role-key>
    API_KEY=riffr-dev-secret-123
    PORT=3000

In AWS Lambda, these values are configured in the function’s Environment
variables section and are not committed to git.

A dedicated IAM user (`riff-api-deployer`) is used for Serverless deployments.
This user currently has the AWS-managed AdministratorAccess policy attached,
which is broad but acceptable for a classroom prototype. In a production
setting it would be replaced with a custom least-privilege policy granting only
the permissions needed for Lambda, API Gateway, CloudWatch, Amplify, and a
secrets/parameter store.

---

## Monitoring, logs & alerts

- Lambda logs for riffr-api-dev-app are written to the CloudWatch log group  
  `/aws/lambda/riffr-api-dev-app`, with log retention set to 30 days.
- A CloudWatch alarm is configured on the Errors metric for riffr-api-dev-app
  to trigger when there are 10 or more errors in a 5-minute window. The alarm
  sends an email notification via an SNS topic subscribed to the developer.

To view logs:

1. Open the CloudWatch console in region us-west-2.
2. Go to Logs → Log groups → /aws/lambda/riffr-api-dev-app.
3. Open recent log streams to inspect requests, errors, and stack traces.

---

## Support, feedback & analytics

### Support contact

- Primary contact: Nick (via class Slack / email).

### Feedback plan

- Share the production URL:
  https://main.d2eqw1u0trx2o8.amplifyapp.com
- Ask classmates/testers to:
  - try Discover, Browse, My Profile, and Messages
  - give feedback on navigation, clarity of matches, and overall UX
- Collect responses in a simple Google Form or document for future iterations.

### Analytics (future work)

- No analytics are enabled in this prototype.
- A future version could add lightweight analytics (e.g. Plausible or Google
  Analytics) to track:
  - which genre filters are used most often
  - clicks on “View profile” vs “Open messages”
  - overall traffic and active sessions.
