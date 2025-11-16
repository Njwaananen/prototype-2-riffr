#!/usr/bin/env bash
set -e  # fail on first error

echo "[smoke] starting Riffr API smoke test..."

# Load env from ../api/.env if present
if [ -f "../api/.env" ]; then
  export $(grep -v '^#' ../api/.env | xargs)
fi

BASE_URL="${BASE_URL:-http://localhost:3000}"
echo "[smoke] BASE_URL=${BASE_URL}"

# 1) GET /api/health
echo
echo "[smoke] GET /api/health"
curl -fsS "${BASE_URL}/api/health"
echo

# 2) GET /api/profiles
echo
echo "[smoke] GET /api/profiles"
curl -fsS "${BASE_URL}/api/profiles"
echo

# 3) GET /api/profiles/search/by-genre?genre=hip-hop
echo
echo "[smoke] GET /api/profiles/search/by-genre?genre=hip-hop"
curl -fsS "${BASE_URL}/api/profiles/search/by-genre?genre=hip-hop"
echo

# 4) POST /api/profiles (write)
echo
echo "[smoke] POST /api/profiles"
curl -fsS \
  -H "Content-Type: application/json" \
  -X POST \
  -d '{
    "email": "testuser@example.com",
    "username": "testuser123",
    "password": "testpassword",
    "display_name": "Test User",
    "bio": "Created by smoke test",
    "location_text": "Test City"
  }' \
  "${BASE_URL}/api/profiles"
echo

echo
echo "[smoke] all requests succeeded"
