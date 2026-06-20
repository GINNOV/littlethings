import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { fetchBookmarks, fetchBookmarkFolders } from "@/lib/x";
import { fetchYouTubeBookmarks } from "@/lib/youtube";
import { getSettings, getUsageMonth, incrementUsage, updateSettings } from "@/lib/settings";
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
  const sourceParam = url.searchParams.get("source");
  const source: "x" | "yt" = sourceParam === "yt" ? "yt" : "x";

  const active = await getActiveRun(source);
  if (active) {
    return NextResponse.json(
      { ok: false, error: `A sync is already running for ${source.toUpperCase()}.` },
      { status: 409 }
    );
  }

  const run = await prisma.importRun.create({
    data: { notes: `source:${source}` },
  });
  const operation = await createOperationRun({
    type: source === "yt" ? "youtube_sync" : "x_sync",
    source,
    status: "running",
  });

  try {
    const settings = await getSettings();
    let remaining: number | null = null;
    if (source === "x") {
      const usage = await getUsageMonth(new Date(), "x");
      const cap = settings.monthlyCap ?? 100;
      remaining = cap - usage.usedBookmarks;

      if (remaining <= 0) {
        await prisma.importRun.update({
          where: { id: run.id },
          data: {
            finishedAt: new Date(),
            notes: "Monthly bookmark limit reached.",
          },
        });
        await updateOperationRun(operation.id, {
          status: "stopped",
          notes: "Monthly bookmark limit reached.",
          finish: true,
        });
        return NextResponse.json(
          {
            ok: false,
            error: "Monthly bookmark limit reached.",
            runId: run.id,
            remaining,
          },
          { status: 429 }
        );
      }
    }

    let bookmarks: any[] = [];
    if (source === "yt") {
      bookmarks = await fetchYouTubeBookmarks({ maxTotal: undefined });
    } else {
      // Deep Folder Sync for X
      
      // Fetch fresh folders from X to discovery new ones
      try {
        const xFolders = await fetchBookmarkFolders();
        for (const xf of xFolders) {
          await prisma.bookmarkFolder.upsert({
            where: { id: xf.id },
            update: { name: xf.name ?? null },
            create: { id: xf.id, name: xf.name ?? null }
          });
          
          await logProcessingEvent({
            runId: operation.id,
            type: "import",
            status: "fetching",
            message: `Syncing X folder: ${xf.name || xf.id}...`,
          });

          const folderBookmarks = await fetchBookmarks({
            folderId: xf.id,
            folderName: xf.name,
            maxTotal: remaining ?? undefined,
          });
          
          await logProcessingEvent({
            runId: operation.id,
            type: "import",
            status: "completed",
            message: `Fetched ${folderBookmarks.length} bookmarks from X folder: ${xf.name || xf.id}.`,
          });

          bookmarks.push(...folderBookmarks);
        }
      } catch (e: unknown) {
        console.warn("Failed to fetch X folders, continuing with global sync:", e);
        await logProcessingEvent({
          runId: operation.id,
          type: "import",
          status: "failed",
          message: `Folder discovery failed: ${e instanceof Error ? e.message : String(e)}. Falling back to global sync.`,
        });
      }

      // Finally, fetch global bookmarks to catch anything not in a folder
      await logProcessingEvent({
        runId: operation.id,
        type: "import",
        status: "fetching",
        message: `Syncing global X bookmarks (catch-all)...`,
      });

      const globalBookmarks = await fetchBookmarks({
        maxTotal: remaining ?? undefined,
        stopBeforeIds: settings.lastBookmarkId ? new Set([settings.lastBookmarkId]) : undefined,
      });
      bookmarks.push(...globalBookmarks);

      // Deduplicate by ID - folder specific entries win (they have folderId)
      const bookmarkMap = new Map<string, typeof bookmarks[0]>();
      for (const b of bookmarks) {
        // Only overwrite if we don't have it yet, OR if this new one has a folderId and the existing one doesn't
        if (!bookmarkMap.has(b.id) || (b.folderId && !bookmarkMap.get(b.id).folderId)) {
          bookmarkMap.set(b.id, b);
        }
      }
      bookmarks = Array.from(bookmarkMap.values());
      
      await logProcessingEvent({
        runId: operation.id,
        type: "import",
        status: "completed",
        message: `Total deduplicated X bookmarks: ${bookmarks.length}.`,
      });
    }

    const existingIds = bookmarks.length
      ? new Set(
          (
            await prisma.bookmark.findMany({
              where: { id: { in: bookmarks.map((b: { id: string }) => b.id) } },
              select: { id: true },
            })
          ).map((b) => b.id)
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

      if (bookmark.folderId) {
        await prisma.bookmarkFolder.upsert({
          where: { id: bookmark.folderId },
          update: { name: bookmark.folderName ?? undefined },
          create: {
            id: bookmark.folderId,
            name: bookmark.folderName ?? null,
          },
        });
      }

      await prisma.bookmark.upsert({
        where: { id: bookmark.id },
        update: {
          source,
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
          ...(bookmark.folderId ? { folder: { connect: { id: bookmark.folderId } } } : {}),
        },
        create: {
          id: bookmark.id,
          source,
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
          ...(bookmark.folderId ? { folder: { connect: { id: bookmark.folderId } } } : {}),
        },
      });
      await logProcessingEvent({
        runId: operation.id,
        bookmarkId: bookmark.id,
        type: "import",
        status: existingIds.has(bookmark.id) ? "skipped" : "completed",
        message: existingIds.has(bookmark.id)
          ? "Existing bookmark refreshed."
          : "New bookmark imported.",
        metadata: { source, folderId: bookmark.folderId ?? null },
      });
    }

    if (source === "x" && created > 0) {
      await incrementUsage(created, "x");
    }

    if (bookmarks.length > 0 && source === "x") {
      // Find the most recent bookmark from the global sync if possible
      // to keep the baseline correct. 
      const latestGlobal = bookmarks.find(b => !b.folderId) || bookmarks[0];
      await updateSettings({
        lastBookmarkId: latestGlobal.id,
        lastSyncedAt: new Date(),
      });
    }

    await prisma.importRun.update({
      where: { id: run.id },
      data: {
        finishedAt: new Date(),
        totalFetched: bookmarks.length,
      },
    });
    await updateOperationRun(operation.id, {
      status: "completed",
      total: bookmarks.length,
      processed: bookmarks.length,
      updated: created,
      skipped: refreshed,
      notes: `Imported ${created} new. Refreshed ${refreshed} existing.`,
      finish: true,
    });

    return NextResponse.json({
      ok: true,
      source,
      imported: created,
      refreshed,
      fetched: bookmarks.length,
      runId: run.id,
      remaining: source === "x" && remaining !== null ? remaining - created : null,
      message: created === 0 && settings.lastBookmarkId && source === "x"
        ? "No new bookmarks found since your last sync baseline. Use Settings to reset the baseline if you are missing older bookmarks."
        : undefined,
    });
  } catch (error) {
    const status =
      (error as Error & { code?: string })?.code === "YOUTUBE_QUOTA" ? 429 : 500;
    await prisma.importRun.update({
      where: { id: run.id },
      data: {
        finishedAt: new Date(),
        notes: error instanceof Error ? error.message : "Unknown error",
      },
    });
    await updateOperationRun(operation.id, {
      status: "failed",
      notes: error instanceof Error ? error.message : "Unknown error",
      finish: true,
    });

    return NextResponse.json(
      {
        ok: false,
        error: error instanceof Error ? error.message : "Unknown error",
        runId: run.id,
      },
      { status }
    );
  }
}
