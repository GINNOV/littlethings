const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

function copyRecursiveSync(src, dest) {
  const exists = fs.existsSync(src);
  const stats = exists && fs.statSync(src);
  const isDirectory = exists && stats.isDirectory();
  if (isDirectory) {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, { recursive: true });
    }
    fs.readdirSync(src).forEach((childItemName) => {
      copyRecursiveSync(
        path.join(src, childItemName),
        path.join(dest, childItemName)
      );
    });
  } else {
    fs.copyFileSync(src, dest);
  }
}

console.log("1. Running production next build...");
execSync("npm run build", { stdio: "inherit" });

const standaloneDir = path.join(__dirname, "..", ".next", "standalone");
const tauriResourcesDir = path.join(__dirname, "..", "src-tauri", "resources");
const tauriServerDir = path.join(tauriResourcesDir, "server");
const tauriBinDir = path.join(tauriResourcesDir, "bin");

// Clean existing resources folder
if (fs.existsSync(tauriResourcesDir)) {
  fs.rmSync(tauriResourcesDir, { recursive: true, force: true });
}
fs.mkdirSync(tauriServerDir, { recursive: true });
fs.mkdirSync(tauriBinDir, { recursive: true });

console.log("2. Copying standalone files to Tauri resources...");
copyRecursiveSync(standaloneDir, tauriServerDir);

console.log("3. Copying public assets to Tauri resources...");
const publicSrc = path.join(__dirname, "..", "public");
const publicDest = path.join(tauriServerDir, "public");
if (fs.existsSync(publicSrc)) {
  copyRecursiveSync(publicSrc, publicDest);
}

console.log("4. Copying next static assets to Tauri resources...");
const staticSrc = path.join(__dirname, "..", ".next", "static");
const staticDest = path.join(tauriServerDir, ".next", "static");
if (fs.existsSync(staticSrc)) {
  copyRecursiveSync(staticSrc, staticDest);
}

console.log("5. Copying prisma schema and migrations to Tauri resources...");
const prismaSrc = path.join(__dirname, "..", "prisma");
const prismaDest = path.join(tauriServerDir, "prisma");
if (fs.existsSync(prismaSrc)) {
  copyRecursiveSync(prismaSrc, prismaDest);
}

console.log("6. Copying start-server.js to Tauri resources...");
const startServerSrc = path.join(__dirname, "..", "start-server.js");
const startServerDest = path.join(tauriServerDir, "start-server.js");
if (fs.existsSync(startServerSrc)) {
  fs.copyFileSync(startServerSrc, startServerDest);
}

console.log("7. Copying node binary to Tauri resources...");
const systemNode = "/Users/megov/.local/bin/node";
const destNode = path.join(tauriBinDir, "node");
if (fs.existsSync(systemNode)) {
  fs.copyFileSync(systemNode, destNode);
  fs.chmodSync(destNode, 0o755); // make executable
  console.log(`Copied node binary from ${systemNode} to ${destNode}`);
} else {
  console.error(`ERROR: Node binary not found at ${systemNode}`);
  process.exit(1);
}

console.log("Standalone desktop build complete! Location: src-tauri/resources/");
