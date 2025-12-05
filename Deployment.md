# Riffr Deployment Notes

## Frontend (AWS Amplify)

- App name: prototype-2-riffr
- Prod branch: main
- URL: https://main.d2eqw1u0trx2o8.amplifyapp.com

Deployment:

- Triggered automatically on: git push origin main
- To redeploy a specific commit: use the Amplify console “Redeploy this version” button for that build.

---

## Backend API (Lambda + API Gateway via Serverless)

- Service: riffr-api
- Stage: dev
- Region: us-west-2
- Lambda function name: riffr-api-dev-app
- API Gateway endpoint base:
  https://swx5z75dob.execute-api.us-west-2.amazonaws.com
- API base used by the client:
  https://swx5z75dob.execute-api.us-west-2.amazonaws.com/api

Deployment commands (from api/):

    # set env vars for this shell
    export SUPABASE_URL="https://<your-project>.supabase.co"
    export SUPABASE_SERVICE_ROLE_KEY="<service-role-key>"
    export API_KEY="riffr-dev-secret-123"

    # deploy current version
    npx serverless deploy

---

## Supabase

- Project name: <FILL THIS IN from Supabase dashboard>
- Project URL: https://<your-project>.supabase.co

Schema & seed scripts:

- db/01_schema.sql
- db/02_seed.sql

To recreate the demo data on a clean project:

1. Run 01_schema.sql in the Supabase SQL editor.
2. Run 02_seed.sql to insert demo profiles.

---

## Backups & Rollback

### Supabase backups

- Supabase maintains automatic backups (see Project Settings → Backups).
- Before major migrations, verify there is a recent backup available.

### API rollback (Serverless / Lambda)

From the api/ folder:

    # show available rollback timestamps
    npx serverless rollback

    # roll back to a known good deployment
    npx serverless rollback --timestamp <timestamp-from-list>

### Frontend rollback (Amplify)

- In the Amplify console, open prototype-2-riffr → main branch.
- Select a previous successful build and click “Redeploy this version” to restore that build.

---

## Support & Feedback

- Support contact: Contact Nick on Slack
- Feedback plan: share the Amplify URL with classmates and collect comments
  on navigation, matching quality, and UI in a short survey / Google Form.

---

## Analytics (future work)

- In a future iteration, add lightweight analytics to track:
  - Genre filters used
  - Clicks on "View profile" vs "Open messages"
