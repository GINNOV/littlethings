import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { enrichmentSignals } from "@/lib/signals";

export const dynamic = "force-dynamic";

export async function POST() {
  try {
    const updated = await prisma.operationRun.updateMany({
      where: {
        status: { in: ["running", "queued"] },
      },
      data: {
        status: "stopped",
        finishedAt: new Date(),
      },
    });

    // Abort all active signals
    for (const [runId, controller] of enrichmentSignals.entries()) {
      controller.abort();
      enrichmentSignals.delete(runId);
    }

    return NextResponse.json({ ok: true, stoppedCount: updated.count });
  } catch (error) {
    console.error("Failed to stop all runs:", error);
    return NextResponse.json(
      { ok: false, error: "Internal server error" },
      { status: 500 }
    );
  }
}
