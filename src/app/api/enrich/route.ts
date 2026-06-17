import { NextResponse } from "next/server";
import type { OperationRun } from "@prisma/client";
import { prisma } from "@/lib/db";
import { summarizeBookmark, validateModelAvailability } from "@/lib/llm";
import { fetchYouTubeTranscriptFromUrl } from "@/lib/youtubeTranscript";
import { enrichmentSignals } from "@/lib/signals";
import {
  createOperationRun,
  logProcessingEvent,
  updateOperationRun,
  incrementOperationRun,
  getActiveRun,
} from "@/lib/processing";

export const dynamic = "force-dynamic";
export const maxDuration = 300;
const MAX_ENRICH_CONCURRENCY = 6;
const SAFETY_MARGIN_MS = 20000; // Stop 20s before timeout

function parseExternalUrls(input: string | null) {
  if (!input) return undefined;
  try {
    const parsed = JSON.parse(input);
    return Array.isArray(parsed) ? parsed : undefined;
  } catch {
    return undefined;
  }
}

async function fetchUrlText(url: string) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 8000);
  try {
    const res = await fetch(url, {
      signal: controller.signal,
      headers: { "User-Agent": "XBookmarkAtlas/1.0" },
    });
    if (!res.ok) return null;
    const html = await res.text();
    const cleaned = html
      .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, " ")
      .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, " ")
      .replace(/<[^>]+>/g, " ")
      .replace(/\s+/g, " ")
      .trim();
    return cleaned.slice(0, 3000);
  } catch {
    return null;
  } finally {
    clearTimeout(timeout);
  }
}

function isExternalContentUrl(url: string) {
  try {
    const host = new URL(url).hostname.toLowerCase();
    return !(
      host.endsWith("x.com") ||
      host.endsWith("twitter.com") ||
      host.endsWith("t.co")
    );
  } catch {
    return false;
  }
}

async function buildSourceText(urls?: string[]) {
  if (!urls || urls.length === 0) return undefined;
  const texts: string[] = [];
  const filtered = urls.filter(isExternalContentUrl);
  for (const url of filtered.slice(0, 2)) {
    const text = await fetchUrlText(url);
    if (text) texts.push(text);
  }
  return texts.length ? texts.join("\n---\n") : undefined;
}

function buildYoutubeFallbackSummary(input: { transcript?: string | null; text?: string | null }) {
  const base = (input.transcript ?? input.text ?? "").replace(/\s+/g, " ").trim();
  if (!base) return null;
  return base.length > 360 ? `${base.slice(0, 357)}...` : base;
}

export async function POST(request: Request) {
  const startTime = Date.now();
  const url = new URL(request.url);
  const limitParam = url.searchParams.get("limit"), concurrencyParam = url.searchParams.get("concurrency");
  const sourceParam = url.searchParams.get("source"), folderIdParam = url.searchParams.get("folderId");
  const runIdParam = url.searchParams.get("runId"), fullParam = url.searchParams.get("full") === "true";
  
  const source = sourceParam === "x" || sourceParam === "yt" ? sourceParam : null;
  const folderId = folderIdParam?.trim() ? folderIdParam.trim() : null;

  if (!runIdParam) {
    const active = await getActiveRun(source);
    if (active) return NextResponse.json({ ok: false, error: `An operation is already running for ${source?.toUpperCase() || "the library"}.` }, { status: 409 });
  }

  const settings = await prisma.settings.findUnique({ where: { id: "default" } });
  const batchLimit = limitParam ? Math.max(1, Number(limitParam)) : (source === "yt" ? 100 : (settings?.enrichBatchSize ?? 50));
  const concurrency = concurrencyParam ? Math.min(MAX_ENRICH_CONCURRENCY, Math.max(1, Number(concurrencyParam))) : settings?.llmConcurrency ?? 1;

  const pendingWhere = { 
    AND: [
      { OR: [{ summary: null }, { summary: "" }] },
      { OR: [{ category: null }, { category: "" }] }
    ],
    ...(!fullParam ? { enrichmentFailures: { lt: 3 } } : {}),
    ...(source ? { source } : {}), 
    ...(folderId ? { folderId } : {}) 
  };

  let run: OperationRun | null = null;
  if (runIdParam) {
    run = await prisma.operationRun.findUnique({ where: { id: runIdParam } });
    if (run) await prisma.operationRun.update({ where: { id: run.id }, data: { status: "running" } });
  }
  
  if (!run) {
    const totalPending = await prisma.bookmark.count({ where: pendingWhere });
    run = await createOperationRun({ type: folderId ? "folder_enrichment" : "enrichment_batch", source, total: totalPending, notes: `${folderId ? `folder:${folderId}` : `batch:${batchLimit}`}. concurrency:${concurrency}` });
  }

  if (!run) return NextResponse.json({ ok: false, error: "Failed to initialize operation run" }, { status: 500 });
  const activeRun = run;
  const attemptedIds = new Set<string>();

  try {
    await validateModelAvailability();
  } catch (error) {
    const message = error instanceof Error ? error.message : "LLM pre-flight check failed.";
    await logProcessingEvent({ runId: activeRun.id, type: "system", status: "failed", message: `Enrichment aborted: ${message}` });
    await prisma.operationRun.update({ where: { id: activeRun.id }, data: { status: "failed", finishedAt: new Date(), notes: message } });
    return NextResponse.json({ ok: false, error: message }, { status: 503 });
  }

  let totalProcessed = 0, totalUpdated = 0, totalErrors: Array<{ id: string; error: string }> = [];
  let controller = enrichmentSignals.get(activeRun.id);
  if (!controller) { controller = new AbortController(); enrichmentSignals.set(activeRun.id, controller); }
  const signal = controller.signal;
  
  try {
    while (true) {
      if (Date.now() - startTime > (maxDuration * 1000) - SAFETY_MARGIN_MS) {
        await logProcessingEvent({ runId: activeRun.id, type: "system", status: "skipped", message: "Approaching server timeout. Stopping batch." });
        break;
      }
      if (signal.aborted) break;

      const pendingBatch = await prisma.bookmark.findMany({ where: { ...pendingWhere, id: { notIn: Array.from(attemptedIds) } }, take: batchLimit, orderBy: { importedAt: "desc" }, include: { folder: true } });
      if (pendingBatch.length === 0) break;
      for (const b of pendingBatch) attemptedIds.add(b.id);

      let batchNextIndex = 0, batchUpdated = 0;
      const batchErrors: Array<{ id: string; error: string }> = [];

      async function processBookmark(bookmark: (typeof pendingBatch)[number]) {
        try {
          if (signal.aborted) return;
          await logProcessingEvent({ runId: activeRun.id, bookmarkId: bookmark.id, type: "bookmark", status: "fetching", message: "Preparing bookmark." });
          const isYouTube = bookmark.source === "yt";
          const transcript = isYouTube ? await fetchYouTubeTranscriptFromUrl(bookmark.tweetUrl) : null;
          const externalUrls = parseExternalUrls(bookmark.externalUrls);
          const sourceText = transcript ?? (await buildSourceText(externalUrls));
          const enrichmentText = isYouTube ? (sourceText ? undefined : bookmark.text ?? undefined) : bookmark.text ?? undefined;

          if (signal.aborted) return;
          const enrichment = await summarizeBookmark({ text: enrichmentText, folderName: bookmark.folder?.name ?? undefined, authorUsername: bookmark.authorUsername ?? undefined, externalUrls, sourceText, mediaDescription: bookmark.mediaDescription ?? undefined, signal, processing: { runId: activeRun.id, bookmarkId: bookmark.id } });
          const summary = enrichment.summary?.trim() || (isYouTube ? buildYoutubeFallbackSummary({ transcript, text: bookmark.text }) : null);

          await prisma.bookmark.update({ 
            where: { id: bookmark.id }, 
            data: { 
              summary, 
              category: enrichment.category, 
              tags: enrichment.tags?.length ? enrichment.tags.join(", ") : null, 
              embedding: enrichment.embedding ? Buffer.from(new Float32Array(enrichment.embedding).buffer) : null, 
              summarizedAt: new Date(), 
              editedAt: null,
              enrichmentError: null,
              enrichmentFailures: 0
            } 
          });
          batchUpdated += 1;
          await logProcessingEvent({ runId: activeRun.id, bookmarkId: bookmark.id, type: "bookmark", status: "completed", message: "Saved.", metadata: { category: enrichment.category, usedTranscript: !!transcript } });
          await incrementOperationRun(activeRun.id, { status: "running", processed: 1, updated: 1 });
        } catch (error) {
          const errMsg = error instanceof Error ? error.message : "Unknown error";
          batchErrors.push({ id: bookmark.id, error: errMsg });
          await prisma.bookmark.update({
            where: { id: bookmark.id },
            data: { 
              enrichmentError: errMsg,
              enrichmentFailures: { increment: 1 }
            }
          });
          await logProcessingEvent({ runId: activeRun.id, bookmarkId: bookmark.id, type: "bookmark", status: "failed", message: errMsg });
          await incrementOperationRun(activeRun.id, { status: "running", processed: 1, failed: 1 });
        }
      }

      async function worker() {
        while (true) {
          if (signal.aborted) return;
          if (Date.now() - startTime > (maxDuration * 1000) - SAFETY_MARGIN_MS) return;
          const cur = await prisma.operationRun.findUnique({ where: { id: activeRun.id }, select: { status: true } });
          if (cur?.status === "stopped") return;
          const idx = batchNextIndex; batchNextIndex += 1;
          if (idx >= pendingBatch.length) return;
          await processBookmark(pendingBatch[idx]);
        }
      }

      await Promise.all(Array.from({ length: Math.min(concurrency, pendingBatch.length || 1) }, () => worker()));
      const actuallyAttempted = Math.min(batchNextIndex, pendingBatch.length);
      totalProcessed += actuallyAttempted; totalUpdated += batchUpdated; totalErrors = [...totalErrors, ...batchErrors];
      
      if (!fullParam) break;
    }
  } finally {
    const rem = await prisma.bookmark.count({ where: pendingWhere });
    const isTotalFailure = totalErrors.length === totalProcessed && totalProcessed > 0;
    const finalStatus = signal.aborted ? "stopped" : (rem === 0 ? "completed" : (isTotalFailure ? "failed" : "completed"));

    await updateOperationRun(activeRun.id, { status: finalStatus, notes: totalErrors.length > 0 ? `Finished with ${totalErrors.length} errors.` : `Completed.`, finish: true });
    enrichmentSignals.delete(activeRun.id);
  }

  const remFinal = await prisma.bookmark.count({ where: pendingWhere });
  return NextResponse.json({ ok: true, runId: activeRun.id, processed: totalProcessed, updated: totalUpdated, remaining: remFinal, errors: totalErrors, finished: remFinal === 0 });
}
