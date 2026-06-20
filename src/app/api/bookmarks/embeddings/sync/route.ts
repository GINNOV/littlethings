import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { generateEmbedding } from "@/lib/llm";
import {
  createOperationRun,
  logProcessingEvent,
  updateOperationRun,
  incrementOperationRun,
} from "@/lib/processing";

export const dynamic = "force-dynamic";
export const maxDuration = 300;

export async function POST(request: Request) {
  const url = new URL(request.url);
  const limitParam = url.searchParams.get("limit");
  const limit = limitParam ? Math.max(1, Number(limitParam)) : 100;

  const pending = await prisma.bookmark.findMany({
    where: { 
      embedding: null,
      OR: [
        { summary: { not: null } },
        { summary: { not: "" } }
      ]
    },
    take: limit,
    orderBy: { importedAt: "desc" },
  });

  if (pending.length === 0) {
    return NextResponse.json({ ok: true, message: "No bookmarks need embedding sync." });
  }

  const run = await createOperationRun({
    type: "embedding_sync",
    source: "system",
    total: pending.length,
    notes: `Syncing embeddings for ${pending.length} bookmarks.`,
  });

  let updated = 0;
  let failed = 0;

  for (const bookmark of pending) {
    try {
      const text = `${bookmark.summary}\n${bookmark.category}\n${bookmark.tags ?? ""}`;
      const embedding = await generateEmbedding(text);
      
      await prisma.bookmark.update({
        where: { id: bookmark.id },
        data: {
          embedding: Buffer.from(new Float32Array(embedding).buffer),
        },
      });

      updated += 1;
      await incrementOperationRun(run.id, {
        status: "running",
        processed: 1,
        updated: 1,
      });
    } catch (error) {
      failed += 1;
      await logProcessingEvent({
        runId: run.id,
        bookmarkId: bookmark.id,
        type: "system",
        status: "failed",
        message: error instanceof Error ? error.message : "Embedding failed",
      });
      await incrementOperationRun(run.id, {
        status: "running",
        processed: 1,
        failed: 1,
      });
    }
  }

  await updateOperationRun(run.id, {
    status: "completed",
    finish: true,
  });

  return NextResponse.json({ ok: true, updated, failed, runId: run.id });
}
