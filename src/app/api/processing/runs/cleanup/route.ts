import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { enrichmentSignals } from "@/lib/signals";

export const dynamic = "force-dynamic";

/**
 * Handles cleaning up orphaned "running" or "queued" jobs.
 * This is useful when the server restarts or a job loses its connection.
 */
export async function POST() {
  try {
    const updated = await prisma.operationRun.updateMany({
      where: {
        status: { in: ["running", "queued"] },
      },
      data: {
        status: "failed",
        finishedAt: new Date(),
        notes: "Orphaned process marked as failed during manual cleanup.",
      },
    });

    // Clear any abandoned memory signals
    enrichmentSignals.clear();

    return NextResponse.json({ 
      ok: true, 
      cleanedCount: updated.count,
      message: `Successfully cleaned up ${updated.count} stuck operations.`
    });
  } catch (error) {
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : "Cleanup failed" },
      { status: 500 }
    );
  }
}
