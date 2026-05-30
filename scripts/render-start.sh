#!/bin/sh
set -e

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is not set."
  echo "Render → Web Service → Environment → Add from database (Postgres)."
  exit 1
fi

case "$DATABASE_URL" in
  *localhost*|*127.0.0.1*)
    echo "ERROR: DATABASE_URL points to localhost. Use Render Postgres Internal URL."
    exit 1
    ;;
esac

export SEED_PROFILE="${SEED_PROFILE:-demo}"

echo "Prisma generate..."
npx prisma generate

echo "Running migrations..."
npx prisma migrate deploy

# Seed on Render often times out — run locally: npm run seed:admin or .\scripts\seed-local.ps1
if [ "${SEED_IF_EMPTY:-false}" = "true" ]; then
  echo "Database seed (if empty)..."
  npm run seed:if-empty || echo "WARN: seed skipped (run locally: npm run seed:admin)"
fi

echo "Starting API..."
exec npx tsx src/server.ts
