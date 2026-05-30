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
   | `APP_BASE_URL` | `https://food-delivery-api.onrender.com` (your real Render URL) |
   | `CLIENT_ORIGINS` | `https://fooddelivery93.netlify.app` (your Netlify URL, no trailing slash) |

   Add Stripe keys if you use payments.

6. Wait for **first deploy** to finish (build runs migrations).
7. **Seed database** (once): Render → service → **Shell**:
   ```bash
   npm run postdeploy:seed
   ```

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

Demo admin (if seeded): `admin@admin.com` / `Pass@123`

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
| CORS error on Netlify | Set `CLIENT_ORIGINS` on Render to exact Netlify URL, redeploy API |
| Register fails 500 | Check Render logs; confirm `DATABASE_URL` and migrations ran |
| Slow first request | Render free tier sleeps; wake with health URL |
| Empty Netlify page | Redeploy Netlify; open `/` not `/landing/` |
| `VITE_API_URL` ignored | Redeploy Netlify **after** saving the variable |

Never commit `.env` to GitHub.
