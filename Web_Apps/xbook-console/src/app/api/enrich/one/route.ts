import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { summarizeBookmark } from "@/lib/llm";
import { fetchYouTubeTranscriptFromUrl } from "@/lib/youtubeTranscript";
import {
  createOperationRun,
  logProcessingEvent,
  updateOperationRun,
} from "@/lib/processing";
import { getSettings } from "@/lib/settings";
import { buildEnrichmentRunConfig } from "@/lib/run-config";

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
  const url = new URL(request.url);
  const bookmarkId = url.searchParams.get("bookmarkId");

  if (!bookmarkId) {
    return NextResponse.json({ ok: false, error: "Missing bookmarkId" }, { status: 400 });
  }

  const bookmark = await prisma.bookmark.findUnique({
    where: { id: bookmarkId },
    include: { folder: true },
  });
  if (!bookmark) {
    return NextResponse.json({ ok: false, error: "Bookmark not found" }, { status: 404 });
  }

  const settings = await getSettings();
  const run = await createOperationRun({
    type: "single_reprocess",
    source: bookmark.source,
    total: 1,
    notes: `bookmark:${bookmark.id}`,
    config: buildEnrichmentRunConfig(settings, {
      concurrency: 1,
      batchSize: 1,
      batchIndex: 1,
      totalBatches: 1,
    }),
  });

  try {
    await logProcessingEvent({
      runId: run.id,
      bookmarkId: bookmark.id,
      type: "bookmark",
      status: "fetching",
      message: "Preparing bookmark for reprocess.",
    });
    const externalUrls = parseExternalUrls(bookmark.externalUrls);
    const isYouTube = bookmark.source === "yt";
    const transcript = isYouTube
      ? await fetchYouTubeTranscriptFromUrl(bookmark.tweetUrl)
      : null;
    const sourceText = transcript ?? (await buildSourceText(externalUrls));
    const enrichmentText = isYouTube
      ? sourceText
        ? undefined
        : bookmark.text ?? undefined
      : bookmark.text ?? undefined;

    const enrichment = await summarizeBookmark({
      text: enrichmentText,
      folderName: bookmark.folder?.name ?? undefined,
      authorUsername: bookmark.authorUsername ?? undefined,
      externalUrls,
      sourceText,
      mediaDescription: bookmark.mediaDescription ?? undefined,
      processing: { runId: run.id, bookmarkId: bookmark.id },
    });
    const summary =
      enrichment.summary?.trim() ||
      (isYouTube
        ? buildYoutubeFallbackSummary({
            transcript,
            text: bookmark.text,
          })
        : null);

    const updated = await prisma.bookmark.update({
      where: { id: bookmark.id },
      data: {
        summary,
        category: enrichment.category,
        tags: enrichment.tags?.length ? enrichment.tags.join(", ") : null,
        embedding: enrichment.embedding ? Buffer.from(new Float32Array(enrichment.embedding).buffer) : null,
        summarizedAt: new Date(),
        editedAt: null,
      },
    });

    await logProcessingEvent({
      runId: run.id,
      bookmarkId: bookmark.id,
      type: "bookmark",
      status: "completed",
      message: "Bookmark reprocess saved.",
      metadata: { category: enrichment.category, tags: enrichment.tags },
    });
    await updateOperationRun(run.id, {
      status: "completed",
      processed: 1,
      updated: 1,
      finish: true,
    });

    return NextResponse.json({ ok: true, bookmark: updated, runId: run.id });
  } catch (error) {
    await logProcessingEvent({
      runId: run.id,
      bookmarkId: bookmark.id,
      type: "bookmark",
      status: "failed",
      message: error instanceof Error ? error.message : "Enrich failed",
    });
    await updateOperationRun(run.id, {
      status: "failed",
      processed: 1,
      failed: 1,
      notes: error instanceof Error ? error.message : "Enrich failed",
      finish: true,
    });
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : "Enrich failed" },
      { status: 500 }
    );
  }
}
