import { prisma } from "../src/config/prisma.config.js";
import { runSeed } from "../prisma/seed.js";

async function main() {
  if (!process.env.DATABASE_URL) {
    console.error("ERROR: Set DATABASE_URL (Render Postgres URL or local .env).");
    process.exit(1);
  }

  const users = await prisma.user.count();
  if (users > 0) {
    console.log(`Database already has ${users} user(s) — skipping seed.`);
    console.log("To force reseed: npm run seed  (WARNING: deletes all data)");
    return;
  }

  console.log("Empty database — running seed (demo profile)...");
  await runSeed();
  console.log("Seed finished.");
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
