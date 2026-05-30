FROM node:20-bookworm-slim

WORKDIR /app

# Dependencies + Prisma (client is generated at build, not committed)
COPY package.json package-lock.json ./
COPY prisma.config.ts ./
COPY prisma ./prisma/

RUN npm ci
RUN npx prisma generate

# App source
COPY . .

# Landing UI served at /landing (optional; skip if client folder missing)
RUN if [ -f client/package.json ]; then npm ci --prefix client && npm run build --prefix client; fi

ENV NODE_ENV=production

EXPOSE 4000

# Migrate on start (needs DATABASE_URL from Render env)
CMD ["sh", "-c", "npx prisma migrate deploy && npx tsx src/server.ts"]
