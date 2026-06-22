const { execSync } = require("child_process");
const path = require("path");
const fs = require("fs");
const os = require("os");

// Database and configuration directory (stored outside the app bundle in a known location)
const home = os.homedir();
const appDir = path.join(home, ".xbook");

// Ensure the directory exists
if (!fs.existsSync(appDir)) {
  fs.mkdirSync(appDir, { recursive: true });
}

// Set up server logging to a file in the app support directory
const logFile = path.join(appDir, "server.log");
const logStream = fs.createWriteStream(logFile, { flags: "a" });

// Write a session divider
logStream.write(`\n--- Server Session Started: ${new Date().toISOString()} ---\n`);

// Helper to log errors safely
function logInternalError(message, error) {
  const errMsg = `[xbook-server] ${message}: ${error ? error.stack || error.message || error : ""}\n`;
  logStream.write(errMsg);
  try {
    process.stderr.write(errMsg);
  } catch (e) {}
}

// Redirect stdout and stderr so that we capture all console outputs
const originalStdoutWrite = process.stdout.write.bind(process.stdout);
const originalStderrWrite = process.stderr.write.bind(process.stderr);

process.stdout.write = (chunk, encoding, callback) => {
  try {
    logStream.write(chunk, encoding);
  } catch (e) {}
  return originalStdoutWrite(chunk, encoding, callback);
};

process.stderr.write = (chunk, encoding, callback) => {
  try {
    logStream.write(chunk, encoding);
  } catch (e) {}
  return originalStderrWrite(chunk, encoding, callback);
};

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
    
    // Redirect migration process output directly to log file
    const logFd = fs.openSync(logFile, "a");
    execSync(`"${process.execPath}" "${prismaCliPath}" migrate deploy --config="${prismaConfigPath}"`, {
      stdio: [0, logFd, logFd],
      env: { ...process.env, DATABASE_URL: process.env.DATABASE_URL },
      cwd: __dirname,
    });
    fs.closeSync(logFd);
    console.log("[xbook-server] Database migrations successfully applied.");
  } else {
    console.warn("[xbook-server] Prisma CLI or schema.prisma not found. Skipping auto-migration.");
  }
} catch (err) {
  logInternalError("Database migration failed", err);
  process.exit(1);
}

// Start the Next.js server
console.log("[xbook-server] Starting Next.js standalone server...");
require("./server.js");
