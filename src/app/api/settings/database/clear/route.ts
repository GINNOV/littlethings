import { NextResponse } from "next/server";
import { clearDatabaseData } from "@/lib/db-backup";

export const dynamic = "force-dynamic";

export async function POST() {
  try {
    await clearDatabaseData();
    return NextResponse.json({ ok: true, message: "Database data tables cleared successfully" });
  } catch (error) {
    console.error("Database clear error:", error);
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : "Unknown error" },
      { status: 500 }
    );
  }
}
