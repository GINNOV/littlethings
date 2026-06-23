import path from "path";
import fs from "fs";
import { prisma } from "@/lib/db";

/**
 * Returns the absolute filesystem path to the active SQLite database file.
 */
export function getDbPath(): string {
  const databaseUrl = process.env.DATABASE_URL ?? "file:./dev.db";
  let sqlitePath = databaseUrl.startsWith("file:")
    ? databaseUrl.slice("file:".length)
    : databaseUrl;
  if (!path.isAbsolute(sqlitePath)) {
    sqlitePath = path.resolve(/*turbopackIgnore: true*/ process.cwd(), sqlitePath);
  }
  return sqlitePath;
}

/**
 * Returns the directory path where local database backups are stored,
 * creating it if it doesn't already exist.
 */
export function getBackupDir(): string {
  const dbPath = getDbPath();
  const dbDir = path.dirname(dbPath);
  const backupDir = path.join(dbDir, "backups");
  if (!fs.existsSync(backupDir)) {
    fs.mkdirSync(backupDir, { recursive: true });
  }
  return backupDir;
}

/**
 * Lists all database backup files stored in the backups directory.
 */
export function listBackups() {
  const backupDir = getBackupDir();
  const files = fs.readdirSync(backupDir);
  return files
    .filter((f) => f.endsWith(".db") || f.endsWith(".sqlite"))
    .map((f) => {
      const p = path.join(backupDir, f);
      const stat = fs.statSync(p);
      return {
        filename: f,
        size: stat.size,
        createdAt: stat.birthtime,
      };
    })
    .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
}

/**
 * Copies the active SQLite database file to the backups directory.
 */
export function createBackup(customName?: string) {
  const dbPath = getDbPath();
  if (!fs.existsSync(dbPath)) {
    throw new Error("Active database file not found.");
  }
  const backupDir = getBackupDir();
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  
  let filename = `backup_${timestamp}.db`;
  if (customName) {
    const sanitized = customName.trim().replace(/[^a-zA-Z0-9_-]/g, "_");
    if (sanitized.length > 0) {
      filename = `${sanitized}.db`;
    }
  }
  
  const destPath = path.join(backupDir, filename);
  fs.copyFileSync(dbPath, destPath);
  return { filename, path: destPath };
}

/**
 * Deletes a local backup file from the server.
 */
export function deleteBackup(filename: string): boolean {
  const backupDir = getBackupDir();
  const targetPath = path.join(backupDir, filename);

  // Security check: ensure targetPath is within backupDir (prevent directory traversal)
  const relative = path.relative(backupDir, targetPath);
  if (relative.startsWith("..") || path.isAbsolute(relative)) {
    throw new Error("Invalid backup file path.");
  }

  if (fs.existsSync(targetPath)) {
    fs.unlinkSync(targetPath);
    return true;
  }
  return false;
}

/**
 * Restores a SQLite database file by closing current connections, deleting WAL/SHM files,
 * and overwriting the database file.
 */
export async function restoreBackup(backupPath: string): Promise<boolean> {
  const dbPath = getDbPath();
  if (!fs.existsSync(backupPath)) {
    throw new Error("Backup file to restore not found.");
  }

  // Disconnect prisma client first
  await prisma.$disconnect();

  // Delete current db, wal, shm and journal files to avoid cache mismatch
  const filesToDelete = [
    dbPath,
    `${dbPath}-wal`,
    `${dbPath}-shm`,
    `${dbPath}-journal`,
  ];

  for (const file of filesToDelete) {
    if (fs.existsSync(file)) {
      try {
        fs.unlinkSync(file);
      } catch (err) {
        console.error(`Failed to delete temporary file ${file}:`, err);
      }
    }
  }

  // Copy backup to active database path
  fs.copyFileSync(backupPath, dbPath);
  return true;
}

/**
 * Clears bookmarks, folders, runs and logs but preserves application settings.
 */
export async function clearDatabaseData(): Promise<boolean> {
  // Clear records in dependency order
  await prisma.$transaction([
    prisma.llmRequestLog.deleteMany(),
    prisma.processingEvent.deleteMany(),
    prisma.bookmark.deleteMany(),
    prisma.bookmarkFolder.deleteMany(),
    prisma.operationRun.deleteMany(),
    prisma.importRun.deleteMany(),
    prisma.usageMonth.deleteMany(),
    prisma.oAuthSession.deleteMany(),
  ]);
  return true;
}
