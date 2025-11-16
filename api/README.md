
# Prototype 2 — Local API (Express + Supabase)

This is a minimal starter that matches your Prototype 2 requirements:
- Local API only (no deployment)
- Supabase (service-role) backend
- OpenAPI spec
- cURL smoke test

## Prereqs
- Node 18+
- Supabase project with your schema and seed data
- Values from your Supabase project settings

## Setup
```bash
cd api
cp .env.example .env
# fill in SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY (service role)
npm install
npm run dev
```

API will start on `http://localhost:3001`.

## Endpoints (example)
- `GET /api/health`
- `GET /api/assignments`
- `GET /api/assignments/:id`
- `POST /api/assignments`

> **Note:** The sample routes use an `assignments` table. Replace this with your core table names if different
> and update the smoke test accordingly.

## Local auth
Requests must include `x-api-key: <API_KEY>` header (see `.env`). For teaching/demo, this is a simple shared secret.

## cURL smoke test
From repo root:
```bash
# Linux/Mac
export BASE_URL=http://localhost:3001
export AUTH=local-dev-key
bash tests/smoke.sh

# Windows (PowerShell)
$env:BASE_URL="http://localhost:3001"
$env:AUTH="local-dev-key"
bash tests/smoke.sh
```
The script exits non-zero on failure (good for fast grading).

## OpenAPI
See `api/openapi.yaml`. You can edit, or auto-generate later if you adopt decorators or swagger-jsdoc.

## Where to change table names
- `api/src/routes/assignments.js`
- `tests/smoke.sh`
- `api/openapi.yaml`

## Next steps
- Add more routes and validation
- Replace the sample `assignments` resource with your app’s core entities
- Wire your client to fetch from this API (no direct Supabase calls from the client)
