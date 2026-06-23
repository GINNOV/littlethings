import { NextResponse } from "next/server";
import { listBackups, createBackup, deleteBackup } from "@/lib/db-backup";

export const dynamic = "force-dynamic";

export async function GET() {
  try {
    const list = listBackups();
    return NextResponse.json({ ok: true, backups: list });
  } catch (error) {
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : "Unknown error" },
      { status: 500 }
    );
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json().catch(() => ({}));
    const { customName } = body;
    const result = createBackup(customName);
    return NextResponse.json({ ok: true, ...result });
  } catch (error) {
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : "Unknown error" },
      { status: 500 }
    );
  }
}

export async function DELETE(request: Request) {
  try {
    const body = await request.json().catch(() => ({}));
    const { filename } = body;
    if (!filename) {
      return NextResponse.json({ ok: false, error: "Filename is required" }, { status: 400 });
    }
    const success = deleteBackup(filename);
    return NextResponse.json({ ok: success });
  } catch (error) {
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : "Unknown error" },
      { status: 500 }
    );
  }
}
