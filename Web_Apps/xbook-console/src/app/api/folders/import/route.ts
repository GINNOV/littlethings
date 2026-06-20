import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { fetchBookmarksWithMeta } from "@/lib/x";
import { getSettings, getUsageMonth, incrementUsage } from "@/lib/settings";
import {
  createOperationRun,
  logProcessingEvent,
  updateOperationRun,
  getActiveRun,
} from "@/lib/processing";

export const dynamic = "force-dynamic";
export const maxDuration = 300;

export async function POST(request: Request) {
  const url = new URL(request.url);
  const folderId = url.searchParams.get("folderId");

  if (!folderId) {
    return NextResponse.json({ ok: false, error: "Missing folderId" }, { status: 400 });
  }

  // Validate folderId is numeric (X API requirement)
  if (!/^[0-9]+$/.test(folderId)) {
    return NextResponse.json(
      { ok: false, error: `Invalid folder ID: ${folderId}. X folder IDs must be numeric. This may be stale test data.` },
      { status: 400 }
    );
  }

  const active = await getActiveRun("x");
  if (active) {
    return NextResponse.json(
      { ok: false, error: "A sync or enrichment is already running for X." },
      { status: 409 }
    );
  }

  const operation = await createOperationRun({
    type: "x_folder_import",
    source: "x",
    notes: `folder:${folderId}`,
  });

  try {
    const settings = await getSettings();
    const usage = await getUsageMonth(new Date(), "x");
    const cap = settings.monthlyCap ?? 100;
    const remaining = cap - usage.usedBookmarks;

    if (remaining <= 0) {
      await updateOperationRun(operation.id, {
        status: "stopped",
        notes: "Monthly bookmark limit reached.",
        finish: true,
      });
      return NextResponse.json(
        {
          ok: false,
          error: "Monthly bookmark limit reached.",
          remaining,
        },
        { status: 429 }
      );
    }

    const folderExistingIds = new Set(
      (
        await prisma.bookmark.findMany({
          where: { source: "x", folderId },
          select: { id: true },
        })
      ).map((bookmark) => bookmark.id)
    );
    const fetchResult = await fetchBookmarksWithMeta({
      folderId,
      maxTotal: Math.max(remaining, 10),
      stopBeforeIds: folderExistingIds,
      skipExisting: true, // Don't stop at top, find all missing items
    });
    const bookmarks = fetchResult.items;

    const existingIds = bookmarks.length
      ? new Set(
          (
            await prisma.bookmark.findMany({
              where: { id: { in: bookmarks.map((bookmark) => bookmark.id) } },
              select: { id: true },
            })
          ).map((bookmark) => bookmark.id)
        )
      : new Set<string>();
    let created = 0;
    let refreshed = 0;

    for (const bookmark of bookmarks) {
      if (existingIds.has(bookmark.id)) {
        refreshed += 1;
      } else {
        created += 1;
      }

      await prisma.bookmark.upsert({
        where: { id: bookmark.id },
        update: {
          source: "x",
          tweetUrl: bookmark.tweetUrl,
          text: bookmark.text,
          authorName: bookmark.authorName,
          authorUsername: bookmark.authorUsername,
          createdAt: bookmark.createdAt,
          likeCount: bookmark.likeCount,
          replyCount: bookmark.replyCount,
          retweetCount: bookmark.retweetCount,
          quoteCount: bookmark.quoteCount,
          lang: bookmark.lang,
          externalUrls: bookmark.externalUrls?.length
            ? JSON.stringify(bookmark.externalUrls)
            : null,
          mediaDescription: bookmark.mediaDescription ?? null,
          mediaJson: bookmark.mediaJson ?? null,
          rawJson: bookmark.rawJson,
          folder: { connect: { id: folderId } },
        },
        create: {
          id: bookmark.id,
          source: "x",
          tweetUrl: bookmark.tweetUrl,
          text: bookmark.text,
          authorName: bookmark.authorName,
          authorUsername: bookmark.authorUsername,
          createdAt: bookmark.createdAt,
          likeCount: bookmark.likeCount,
          replyCount: bookmark.replyCount,
          retweetCount: bookmark.retweetCount,
          quoteCount: bookmark.quoteCount,
          lang: bookmark.lang,
          externalUrls: bookmark.externalUrls?.length
            ? JSON.stringify(bookmark.externalUrls)
            : null,
          mediaDescription: bookmark.mediaDescription ?? null,
          mediaJson: bookmark.mediaJson ?? null,
          rawJson: bookmark.rawJson,
          folder: { connect: { id: folderId } },
        },
      });
      await logProcessingEvent({
        runId: operation.id,
        bookmarkId: bookmark.id,
        type: "folder_import",
        status: existingIds.has(bookmark.id) ? "skipped" : "completed",
        message: existingIds.has(bookmark.id)
          ? "Existing folder bookmark refreshed."
          : "New folder bookmark imported.",
        metadata: { folderId, pagesFetched: fetchResult.pagesFetched },
      });
    }

    if (created > 0) {
      await incrementUsage(created, "x");
    }

    await updateOperationRun(operation.id, {
      status: "completed",
      total: bookmarks.length,
      processed: bookmarks.length,
      updated: created,
      skipped: refreshed,
      notes: `X calls: ${fetchResult.pagesFetched}. Imported ${created} new. Refreshed ${refreshed} existing.`,
      finish: true,
    });

    return NextResponse.json({
      ok: true,
      runId: operation.id,
      imported: created,
      refreshed,
      fetched: bookmarks.length,
      pagesFetched: fetchResult.pagesFetched,
      stoppedAtExisting: fetchResult.stoppedAtExisting,
      remaining: remaining - created,
    });
  } catch (error) {
    await updateOperationRun(operation.id, {
      status: "failed",
      notes: error instanceof Error ? error.message : "Import failed",
      finish: true,
    });
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : "Import failed" },
      { status: 500 }
    );
  }
}
