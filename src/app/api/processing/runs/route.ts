import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getProcessingSummary } from "@/lib/processing";

export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  const url = new URL(request.url);
  const source = url.searchParams.get("source");
  const status = url.searchParams.get("status");
  const type = url.searchParams.get("type");
  const errorsOnly = url.searchParams.get("errorsOnly") === "true";
  const take = Math.min(100, Math.max(1, Number(url.searchParams.get("take") ?? 50)));

  const where = {
    ...(source ? { source } : {}),
    ...(status ? { status } : {}),
    ...(type ? { type } : {}),
    ...(errorsOnly ? { OR: [{ failed: { gt: 0 } }, { status: { in: ["failed", "stopped"] } }] } : {}),
  };

  const [runs, summary] = await Promise.all([
    prisma.operationRun.findMany({
      where,
      orderBy: { startedAt: "desc" },
      take,
      include: {
        _count: { select: { events: true, llmRequests: true } },
      },
    }),
    getProcessingSummary(),
  ]);

  return NextResponse.json({ ok: true, runs, summary });
}
