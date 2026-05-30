process.env.SEED_PROFILE = "full";
import { runSeed } from "../prisma/seed.js";
import { prisma } from "../src/config/prisma.config.js";

runSeed()
  .then(() => prisma.$disconnect())
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
