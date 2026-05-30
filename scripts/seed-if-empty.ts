import { execSync } from "node:child_process";
import { prisma } from "../src/config/prisma.config.js";

async function main() {
  const users = await prisma.user.count();
  if (users > 0) {
    console.log(`Database already has ${users} user(s) — skipping seed.`);
    return;
  }

  console.log("Database is empty — running full seed...");
  execSync("tsx prisma/seed.ts", { stdio: "inherit" });
  console.log("Seed finished.");
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
