import { NextResponse } from "next/server";
import path from "path";
import fs from "fs";
import { restoreBackup, getBackupDir } from "@/lib/db-backup";

export const dynamic = "force-dynamic";

export async function POST(request: Request) {
  try {
    const contentType = request.headers.get("content-type") ?? "";

    if (contentType.includes("multipart/form-data")) {
      // 1. Restore from file upload
      const formData = await request.formData();
      const file = formData.get("file") as File | null;
      if (!file) {
        return NextResponse.json({ ok: false, error: "No file uploaded" }, { status: 400 });
      }

      const buffer = Buffer.from(await file.arrayBuffer());

      // Validate SQLite file header: The first 16 bytes must be "SQLite format 3\0"
      const expectedHeader = "SQLite format 3\0";
      if (buffer.length < 16) {
        return NextResponse.json(
          { ok: false, error: "Invalid file. File is too small to be a SQLite database." },
          { status: 400 }
        );
      }
      
      const fileHeader = buffer.toString("utf8", 0, 16);
      if (fileHeader !== expectedHeader) {
        return NextResponse.json(
          { ok: false, error: "Invalid file format. Please upload a valid SQLite database." },
          { status: 400 }
        );
      }

      // Write to a temporary file in the backup directory
      const tempPath = path.join(getBackupDir(), `temp_restore_${Date.now()}.db`);
      fs.writeFileSync(tempPath, buffer);

      try {
        await restoreBackup(tempPath);
      } finally {
        // Clean up temp file
        if (fs.existsSync(tempPath)) {
          fs.unlinkSync(tempPath);
        }
      }

      return NextResponse.json({ ok: true, message: "Database successfully restored from uploaded file" });
    } else if (contentType.includes("application/json")) {
      // 2. Restore from server backup
      const body = await request.json().catch(() => ({}));
      const { filename } = body;
      if (!filename) {
        return NextResponse.json({ ok: false, error: "Filename is required" }, { status: 400 });
      }

      const backupDir = getBackupDir();
      const backupPath = path.join(backupDir, filename);

      // Security traversal check
      const relative = path.relative(backupDir, backupPath);
      if (relative.startsWith("..") || path.isAbsolute(relative)) {
        return NextResponse.json({ ok: false, error: "Invalid backup file path" }, { status: 400 });
      }

      if (!fs.existsSync(backupPath)) {
        return NextResponse.json({ ok: false, error: "Backup file not found on server" }, { status: 404 });
      }

      await restoreBackup(backupPath);
      return NextResponse.json({ ok: true, message: `Database successfully restored from local backup: ${filename}` });
    } else {
      return NextResponse.json({ ok: false, error: "Unsupported content type" }, { status: 400 });
    }
  } catch (error) {
    console.error("Database restore error:", error);
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : "Unknown error" },
      { status: 500 }
    );
  }
}
