import { defineConfig, env } from "@prisma/config";

// Load .env only locally — production (Render) must use injected DATABASE_URL
if (!process.env.DATABASE_URL) {
  await import("dotenv/config");
}

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
    seed: "tsx prisma/seed.ts",
  },
  datasource: {
    url: env("DATABASE_URL"),
  },
});
