const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const STANDALONE_SKIP_DIRS = new Set([
  "src-tauri",
  "tauri-dist",
  "tests",
  ".git",
]);

const STANDALONE_SKIP_FILES = new Set([
  "dev.db",
  "tsconfig.tsbuildinfo",
]);

function shouldSkipStandaloneEntry(name) {
  return STANDALONE_SKIP_DIRS.has(name) || STANDALONE_SKIP_FILES.has(name);
}

function copyRecursiveSync(src, dest, { filter } = {}) {
  const exists = fs.existsSync(src);
  const stats = exists && fs.statSync(src);
  const isDirectory = exists && stats.isDirectory();
  if (isDirectory) {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, { recursive: true });
    }
    fs.readdirSync(src).forEach((childItemName) => {
      if (filter && !filter(childItemName)) {
        return;
      }
      copyRecursiveSync(
        path.join(src, childItemName),
        path.join(dest, childItemName),
        { filter }
      );
    });
  } else {
    fs.copyFileSync(src, dest);
  }
}

console.log("1. Running production next build...");
execSync("npm run build", { stdio: "inherit" });

const standaloneDir = path.join(__dirname, "..", ".next", "standalone");
const tauriDistDir = path.join(__dirname, "..", "tauri-dist");
const tauriResourcesDir = path.join(__dirname, "..", "src-tauri", "resources");
const tauriServerDir = path.join(tauriResourcesDir, "server");
const tauriBinDir = path.join(tauriResourcesDir, "bin");

function copyPackageToServer(packageName) {
  const packageSrc = path.join(__dirname, "..", "node_modules", packageName);
  const packageDest = path.join(tauriServerDir, "node_modules", packageName);
  if (fs.existsSync(packageSrc)) {
    copyRecursiveSync(packageSrc, packageDest);
  }
}

// Clean existing resources folder
if (fs.existsSync(tauriResourcesDir)) {
  fs.rmSync(tauriResourcesDir, { recursive: true, force: true });
}
fs.mkdirSync(tauriServerDir, { recursive: true });
fs.mkdirSync(tauriBinDir, { recursive: true });

if (fs.existsSync(tauriDistDir)) {
  fs.rmSync(tauriDistDir, { recursive: true, force: true });
}
fs.mkdirSync(tauriDistDir, { recursive: true });
fs.writeFileSync(
  path.join(tauriDistDir, "index.html"),
  "<!doctype html><html><head><meta charset=\"utf-8\"><title>XBook Console</title></head><body></body></html>\n"
);

console.log("2. Copying standalone files to Tauri resources...");
copyRecursiveSync(standaloneDir, tauriServerDir, {
  filter: (name) => !shouldSkipStandaloneEntry(name),
});

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

console.log("6. Copying prisma migration runtime and its dependencies to Tauri resources...");
const prismaPackages = [
  "prisma",
  "@prisma/config",
  "@prisma/debug",
  "@prisma/engines",
  "@prisma/engines-version",
  "@prisma/fetch-engine",
  "@prisma/get-platform",
];

const copiedPackages = new Set();
function copyPackageAndDependencies(packageName) {
  if (copiedPackages.has(packageName)) return;
  copiedPackages.add(packageName);

  const packageSrc = path.join(__dirname, "..", "node_modules", packageName);
  const packageDest = path.join(tauriServerDir, "node_modules", packageName);

  if (!fs.existsSync(packageSrc)) {
    return;
  }

  // Copy the package directory
  copyRecursiveSync(packageSrc, packageDest);

  // Read package.json to recursively copy dependencies
  const pkgJsonPath = path.join(packageSrc, "package.json");
  if (fs.existsSync(pkgJsonPath)) {
    try {
      const pkgJson = JSON.parse(fs.readFileSync(pkgJsonPath, "utf8"));
      if (pkgJson.dependencies) {
        Object.keys(pkgJson.dependencies).forEach((depName) => {
          copyPackageAndDependencies(depName);
        });
      }
    } catch (err) {
      console.error(`Failed to parse package.json for ${packageName}:`, err);
    }
  }
}

prismaPackages.forEach(copyPackageAndDependencies);

console.log("7. Copying start-server.js to Tauri resources...");
const startServerSrc = path.join(__dirname, "..", "start-server.js");
const startServerDest = path.join(tauriServerDir, "start-server.js");
if (fs.existsSync(startServerSrc)) {
  fs.copyFileSync(startServerSrc, startServerDest);
}

console.log("8. Copying node binary to Tauri resources...");
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
