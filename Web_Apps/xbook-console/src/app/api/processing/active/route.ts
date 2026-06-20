import { NextResponse } from "next/server";
import { getProcessingSummary } from "@/lib/processing";

export const dynamic = "force-dynamic";

export async function GET() {
  try {
    const summary = await getProcessingSummary();
    return NextResponse.json({
      active: summary.activeOperations > 0,
      count: summary.activeOperations,
    });
  } catch {
    return NextResponse.json({ active: false, count: 0 }, { status: 500 });
  }
}
