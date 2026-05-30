FROM node:20-bookworm-slim

WORKDIR /app

# Prisma 7 config reads DATABASE_URL at generate time (no real DB needed during image build)
ENV DATABASE_URL=postgresql://build:build@127.0.0.1:5432/build?schema=public

COPY package.json package-lock.json ./
COPY prisma.config.ts ./
COPY prisma ./prisma/

# Skip postinstall — we run prisma generate explicitly below
RUN npm ci --ignore-scripts
RUN npx prisma generate

COPY . .

RUN if [ -f client/package.json ]; then npm ci --ignore-scripts --prefix client && npm run build --prefix client; fi

ENV NODE_ENV=production

EXPOSE 4000

CMD ["sh", "-c", "npx prisma migrate deploy && npx tsx src/server.ts"]
