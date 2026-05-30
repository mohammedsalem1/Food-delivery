FROM node:20-bookworm-slim

RUN apt-get update -y \
  && apt-get install -y openssl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Build-time only (prisma generate). Runtime DATABASE_URL must come from Render env.
ARG DATABASE_URL_BUILD=postgresql://build:build@127.0.0.1:5432/build?schema=public

COPY package.json package-lock.json ./
COPY prisma.config.ts ./
COPY prisma ./prisma/

RUN DATABASE_URL="$DATABASE_URL_BUILD" npm ci --ignore-scripts
RUN DATABASE_URL="$DATABASE_URL_BUILD" npx prisma generate

COPY . .

RUN if [ -f client/package.json ]; then npm ci --ignore-scripts --prefix client && npm run build --prefix client; fi

RUN chmod +x scripts/render-start.sh

ENV NODE_ENV=production

EXPOSE 4000

CMD ["./scripts/render-start.sh"]
