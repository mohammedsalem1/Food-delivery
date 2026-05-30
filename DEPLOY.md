# Deploy Food-Delivery (Render + Netlify)

## Architecture

| Service | Host | URL example |
|---------|------|-------------|
| Landing UI | Netlify | `https://fooddelivery93.netlify.app` |
| API + Shop + Dashboard + DB | Render | `https://food-delivery-api.onrender.com` |

---

## 1. Deploy on Render (API + PostgreSQL)

### Option A — Blueprint (recommended)

1. Push code to GitHub (`paymentTest` or `main`).
2. [dashboard.render.com](https://dashboard.render.com) → **New** → **Blueprint**.
3. Connect repo **mohammedsalem1/Food-delivery** (or yours).
4. Render reads `render.yaml` and creates:
   - **PostgreSQL** `food-delivery-db`
   - **Web Service** `food-delivery-api`
5. After create, open the web service → **Environment** and set:

   | Variable | Value |
   |----------|--------|
   | `DATABASE_URL` | **Required.** Link the Render Postgres database (**Add from database**), or paste **Internal Database URL** — never use `localhost:5433` from your local `.env` |
   | `APP_BASE_URL` | `https://food-delivery-api.onrender.com` (your real Render URL) |
   | `CLIENT_ORIGINS` | `https://fooddelivery93.netlify.app` (your Netlify URL, no trailing slash) |

   Add Stripe keys if you use payments.

6. Wait for **first deploy** to finish (build runs migrations).
7. **Seed database** — automatic on deploy if the DB has no users (`SEED_IF_EMPTY=true` in `render.yaml`).  
   Or manually in **Shell** (from `/app`):
   ```bash
   npm run seed:if-empty   # only if database is empty (recommended)
   npm run seed            # demo seed: 10 restaurants (~1 min)
   npm run seed:full       # huge seed: 1000 restaurants (local only, slow)
   ```
   **Accounts after seed:**
   - Admin: `admin@admin.com` / `123456`
   - Shop customer: `customer@demo.com` / `Pass@123`

   **Seed from your PC (Render Shell not required):**

   1. Render → **Postgres** → **Connections** → copy **External Database URL**  
      (not Internal — External works from your computer)

   2. PowerShell — project root (`Food-Delivery`, not `client/`):

   ```powershell
   cd d:\Mentorship-NodeJS\Projects\Food-Delivery

   # Paste your External URL (one line)
   $env:DATABASE_URL="postgresql://USER:PASS@dpg-xxxx.REGION.postgres.render.com/fooddelivery_r7sk"

   # Option A — admin only (fast, does NOT wipe data)
   npx prisma migrate deploy
   npm run seed:admin

   # Option B — full demo data (10 restaurants, wipes existing data)
   npx prisma migrate deploy
   npm run seed

   # Or use the helper script:
   .\scripts\seed-local.ps1 -Mode admin
   .\scripts\seed-local.ps1 -Mode demo
   ```

   3. If `prisma generate` fails locally, run once: `npm run prisma:generate`

8. Test API: open  
   `https://YOUR-SERVICE.onrender.com/api/v1/public/health`  
   → should return `{"ok":true,...}`

### Option B — Manual Web Service

1. **New** → **Web Service** → your repo, branch `paymentTest`.
2. **Build command:**
   ```bash
   npm ci && npx prisma generate && npx prisma migrate deploy && npm run client:build
   ```
3. **Start command:**
   ```bash
   npx tsx src/server.ts
   ```
4. **Health check path:** `/api/v1/public/health`
5. Add **PostgreSQL** from Render dashboard; paste `DATABASE_URL` into the web service env.
6. Copy secrets from `.env.example` (`ACCESS_TOKEN_SECRET`, etc.).

---

## 2. Connect Netlify (register, login, restaurants)

Netlify → **Site configuration** → **Environment variables**:

| Key | Value |
|-----|--------|
| `VITE_API_URL` | `https://YOUR-SERVICE.onrender.com/api/v1` |

**Deploys** → **Clear cache and deploy site**.

Then on Netlify:

- **Register** / **Login** → hit Render API  
- **Restaurants** → loads from database  

---

## 3. Full app URLs on Render

After deploy, use the same Render URL for:

| App | URL |
|-----|-----|
| Shop | `https://YOUR-SERVICE.onrender.com/shop` |
| Dashboard | `https://YOUR-SERVICE.onrender.com/dashboard` |
| Landing (on server) | `https://YOUR-SERVICE.onrender.com/landing` |
| API docs | `https://YOUR-SERVICE.onrender.com/api-docs` |

Demo admin (if seeded): `admin@admin.com` / `123456`

---

## 4. Local development

```bash
npm run dev
# Landing: http://localhost:4000/landing
# Shop:     http://localhost:4000/shop
```

---

## 5. Troubleshooting

| Problem | Fix |
|---------|-----|
| `Cannot find module .../generated/prisma/client` | Build must run `prisma generate`. Redeploy after pulling latest `Dockerfile`. |
| `PrismaConfigEnvError: DATABASE_URL` during Docker build | Fixed: Dockerfile uses build-time placeholder only. Redeploy latest `paymentTest`. |
| `Can't reach database server at localhost:5433` | `DATABASE_URL` on Render is wrong (local `.env`). Link Postgres in Render → **Environment** → **Add from database**. |
| OpenSSL / libssl warning | Fixed in Dockerfile (`apt-get install openssl`). |
| Log shows `npm run dev` / `tsx watch` | Render is using **Docker** with old CMD. **Settings → Runtime**: use **Node** + Start: `npx tsx src/server.ts`, or redeploy with fixed `Dockerfile`. |
| CORS error on Netlify | Set `CLIENT_ORIGINS` on Render to exact Netlify URL, redeploy API |
| Register fails 500 | Check Render logs; confirm `DATABASE_URL` and migrations ran |
| Slow first request | Render free tier sleeps; wake with health URL |
| Empty Netlify page | Redeploy Netlify; open `/` not `/landing/` |
| `VITE_API_URL` ignored | Redeploy Netlify **after** saving the variable |

### Render: Docker vs Node

If deploy logs mention **Docker** / **registry**:

1. **Option A** — Keep Docker: push latest repo (fixed `Dockerfile` runs `prisma generate` + `tsx src/server.ts`).
2. **Option B** — Switch to Node: **Settings** → set **Runtime** to **Node** (not Docker), **Build command** and **Start command** from `render.yaml`, clear Dockerfile path if shown.

Never commit `.env` to GitHub.
