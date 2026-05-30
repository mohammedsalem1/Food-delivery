/**
 * Upsert admin only — safe for Render DB from your PC (does not delete other data).
 * Usage: set DATABASE_URL to Render External URL, then: npm run seed:admin
 */
import { prisma } from "../src/config/prisma.config.js";
import { DEFAULT_ROLE_KEYS } from "../src/utils/constants.js";
import { PasswordUtils } from "../src/utils/password.utils.js";

const ADMIN_EMAIL = "admin@admin.com";
const ADMIN_PASSWORD = "123456";

async function main() {
  if (!process.env.DATABASE_URL) {
    console.error("Set DATABASE_URL first (Render → Postgres → External Database URL).");
    process.exit(1);
  }
  if (process.env.DATABASE_URL.includes("localhost")) {
    console.error("Use Render EXTERNAL URL, not localhost.");
    process.exit(1);
  }

  for (const [name, key] of [
    ["Admin", DEFAULT_ROLE_KEYS.ADMIN],
    ["Customer", DEFAULT_ROLE_KEYS.CUSTOMER],
    ["Restaurant Manager", DEFAULT_ROLE_KEYS.RESTAURANT_MANAGER],
  ]) {
    const exists = await prisma.role.findUnique({ where: { roleKey: key } });
    if (!exists) {
      await prisma.role.create({ data: { roleName: name, roleKey: key } });
    }
  }

  const hash = await PasswordUtils.hash(ADMIN_PASSWORD);
  const existing = await prisma.user.findUnique({ where: { userEmail: ADMIN_EMAIL } });

  if (!existing) {
    await prisma.user.create({
      data: {
        userName: "Super Admin",
        userEmail: ADMIN_EMAIL,
        userPassword: hash,
        isAdmin: true,
        isConfirmed: true,
        isActive: true,
        roles: [DEFAULT_ROLE_KEYS.ADMIN],
      },
    });
    console.log(`Created admin: ${ADMIN_EMAIL} / ${ADMIN_PASSWORD}`);
  } else {
    await prisma.user.update({
      where: { userEmail: ADMIN_EMAIL },
      data: {
        userPassword: hash,
        isAdmin: true,
        isConfirmed: true,
        isActive: true,
        roles: [DEFAULT_ROLE_KEYS.ADMIN],
      },
    });
    console.log(`Updated admin password: ${ADMIN_EMAIL} / ${ADMIN_PASSWORD}`);
  }

  const count = await prisma.restaurant.count();
  if (count === 0) {
    console.log("\nNo restaurants in DB. Run full demo seed locally:");
    console.log("  npm run seed");
  } else {
    console.log(`\nDatabase OK: ${count} restaurant(s).`);
  }
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
