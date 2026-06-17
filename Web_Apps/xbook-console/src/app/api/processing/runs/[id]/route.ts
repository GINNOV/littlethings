import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { enrichmentSignals } from "@/lib/signals";

export const dynamic = "force-dynamic";

export async function GET(
  _request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const run = await prisma.operationRun.findUnique({
    where: { id },
    include: {
      events: {
        orderBy: { createdAt: "asc" },
        include: {
          bookmark: {
            select: {
              id: true,
              source: true,
              tweetUrl: true,
              text: true,
              summary: true,
              category: true,
              tags: true,
              authorUsername: true,
              folder: { select: { id: true, name: true } },
            },
          },
        },
      },
      llmRequests: {
        orderBy: { createdAt: "asc" },
        include: {
          bookmark: {
            select: {
              id: true,
              source: true,
              tweetUrl: true,
              text: true,
              summary: true,
              category: true,
              tags: true,
              authorUsername: true,
              folder: { select: { id: true, name: true } },
            },
          },
        },
      },
    },
  });

  if (!run) {
    return NextResponse.json({ ok: false, error: "Run not found" }, { status: 404 });
  }

  return NextResponse.json({ ok: true, run });
}

export async function POST(
  _request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const run = await prisma.operationRun.findUnique({ where: { id } });

  if (!run) {
    return NextResponse.json({ ok: false, error: "Run not found" }, { status: 404 });
  }

  if (run.status !== "running" && run.status !== "queued") {
    return NextResponse.json({ ok: false, error: "Run is not active" }, { status: 400 });
  }

  const updated = await prisma.operationRun.update({
    where: { id },
    data: { status: "stopped", finishedAt: new Date() },
  });

  // Trigger abort if there is an active signal
  const controller = enrichmentSignals.get(id);
  if (controller) {
    controller.abort();
    enrichmentSignals.delete(id);
  }

  return NextResponse.json({ ok: true, run: updated });
}
