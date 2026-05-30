#!/bin/sh
set -e

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is not set."
  echo "Render → your web service → Environment → link the Postgres database or paste Internal Database URL."
  exit 1
fi

case "$DATABASE_URL" in
  *localhost*|*127.0.0.1*)
    echo "ERROR: DATABASE_URL points to localhost. Use Render Postgres Internal URL, not your local .env value."
    echo "Current value starts with: $(echo "$DATABASE_URL" | cut -c1-40)..."
    exit 1
    ;;
esac

echo "Running migrations..."
npx prisma migrate deploy

# Seed only when DB has no users (set SEED_IF_EMPTY=false to disable)
if [ "${SEED_IF_EMPTY:-true}" = "true" ]; then
  echo "Checking seed (seed:if-empty)..."
  npm run seed:if-empty
fi

echo "Starting API..."
exec npx tsx src/server.ts
