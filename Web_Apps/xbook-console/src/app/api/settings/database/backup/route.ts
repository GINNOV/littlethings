import { NextResponse } from "next/server";
import fs from "fs";
import { getDbPath } from "@/lib/db-backup";

export const dynamic = "force-dynamic";

export async function GET() {
  try {
    const dbPath = getDbPath();
    if (!fs.existsSync(dbPath)) {
      return NextResponse.json({ ok: false, error: "Database file not found" }, { status: 404 });
    }

    const fileBuffer = fs.readFileSync(dbPath);
    
    return new Response(fileBuffer, {
      headers: {
        "Content-Type": "application/octet-stream",
        "Content-Disposition": `attachment; filename="xbook-backup-${new Date().toISOString().slice(0, 10)}.db"`,
      },
    });
  } catch (error) {
    console.error("Backup download error:", error);
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : "Unknown error" },
      { status: 500 }
    );
  }
}
