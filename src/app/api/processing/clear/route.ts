import { NextResponse } from "next/server";
import { clearProcessingLogs } from "@/lib/processing";

export const dynamic = "force-dynamic";

export async function POST() {
  await clearProcessingLogs();
  return NextResponse.json({ ok: true });
}
