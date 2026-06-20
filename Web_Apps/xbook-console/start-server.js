const { execSync } = require("child_process");
const path = require("path");
const fs = require("fs");
const os = require("os");

// Determine the platform-specific application directory for the database
const home = os.homedir();
let appDir;

if (process.platform === "darwin") {
  appDir = path.join(home, "Library", "Application Support", "xbook");
} else if (process.platform === "win32") {
  appDir = path.join(process.env.APPDATA || path.join(home, "AppData", "Roaming"), "xbook");
} else {
  appDir = path.join(home, ".config", "xbook");
}

// Ensure the directory exists
if (!fs.existsSync(appDir)) {
  fs.mkdirSync(appDir, { recursive: true });
}

const dbPath = path.join(appDir, "dev.db");
process.env.DATABASE_URL = `file:${dbPath}`;
console.log(`[xbook-server] Using database at: ${dbPath}`);

// Run Prisma migrations dynamically
try {
  const prismaCliPath = path.join(__dirname, "node_modules", "prisma", "build", "index.js");
  const schemaPath = path.join(__dirname, "prisma", "schema.prisma");
  const prismaConfigPath = path.join(__dirname, "prisma.runtime.config.mjs");

  console.log("[xbook-server] Checking database migrations...");
  if (fs.existsSync(prismaCliPath) && fs.existsSync(schemaPath)) {
    fs.writeFileSync(
      prismaConfigPath,
      [
        'import { defineConfig } from "prisma/config";',
        "export default defineConfig({",
        '  schema: "prisma/schema.prisma",',
        '  migrations: { path: "prisma/migrations" },',
        '  datasource: { url: process.env.DATABASE_URL },',
        "});",
        "",
      ].join("\n")
    );
    execSync(`node "${prismaCliPath}" migrate deploy --config="${prismaConfigPath}"`, {
      stdio: "inherit",
      env: { ...process.env, DATABASE_URL: process.env.DATABASE_URL },
      cwd: __dirname,
    });
    console.log("[xbook-server] Database migrations successfully applied.");
  } else {
    console.warn("[xbook-server] Prisma CLI or schema.prisma not found. Skipping auto-migration.");
  }
} catch (err) {
  console.error("[xbook-server] Database migration failed:", err.message);
  process.exit(1);
}

// Start the Next.js server
console.log("[xbook-server] Starting Next.js standalone server...");
require("./server.js");
