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
    /** Global-only feed items (newest-first). Used solely to advance lastBookmarkId. */
    let globalNewBookmarks: any[] = [];
    let knownSkipped = 0;

    if (source === "yt") {
      bookmarks = await fetchYouTubeBookmarks({ maxTotal: undefined });
    } else {
      // IDs already in the library — never re-hydrate these (X charges per tweet read).
      const existingXIds = new Set(
        (
          await prisma.bookmark.findMany({
            where: { source: "x" },
            select: { id: true },
          })
        ).map((b) => b.id)
      );
      knownSkipped = existingXIds.size;

      // Deep folder scan is expensive (paginated list + tweet lookups). On a normal delta
      // sync with a baseline, new bookmarks always appear on the global list first — so we
      // skip folders unless this is the first sync or the client asked for ?deep=1.
      const deepFolders =
        url.searchParams.get("deep") === "1" || !settings.lastBookmarkId;

      if (deepFolders) {
        try {
          const xFolders = await fetchBookmarkFolders();
          for (const xf of xFolders) {
            await prisma.bookmarkFolder.upsert({
              where: { id: xf.id },
              update: { name: xf.name ?? null },
              create: { id: xf.id, name: xf.name ?? null },
            });

            await logProcessingEvent({
              runId: operation.id,
              type: "import",
              status: "fetching",
              message: `Scanning X folder for new items: ${xf.name || xf.id}…`,
            });

            const folderBookmarks = await fetchBookmarks({
              folderId: xf.id,
              folderName: xf.name,
              maxTotal: remaining ?? undefined,
              stopBeforeIds: existingXIds,
              skipExisting: true,
            });

            for (const b of folderBookmarks) existingXIds.add(b.id);

            await logProcessingEvent({
              runId: operation.id,
              type: "import",
              status: "completed",
              message: `Folder ${xf.name || xf.id}: ${folderBookmarks.length} new to import.`,
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
      } else {
        await logProcessingEvent({
          runId: operation.id,
          type: "import",
          status: "completed",
          message:
            "Delta mode: skipped full folder re-scan (use folder import or ?deep=1 to re-walk folders).",
        });
      }

      // Global bookmarks: delta only.
      // With a baseline, walk newest→oldest and stop at lastBookmarkId (bookmark order).
      // Without a baseline, scan the full list but still skip IDs already in the library.
      await logProcessingEvent({
        runId: operation.id,
        type: "import",
        status: "fetching",
        message: settings.lastBookmarkId
          ? `Delta sync of global X bookmarks (stop at baseline ${settings.lastBookmarkId})…`
          : "Global X bookmark sync (no baseline yet; skipping IDs already in library)…",
      });

      if (settings.lastBookmarkId) {
        globalNewBookmarks = await fetchBookmarks({
          maxTotal: remaining ?? undefined,
          stopBeforeIds: new Set([settings.lastBookmarkId]),
          skipExisting: false,
        });
        // Defensive: never re-store tweets we already paid to import.
        globalNewBookmarks = globalNewBookmarks.filter((b) => !existingXIds.has(b.id));
      } else {
        globalNewBookmarks = await fetchBookmarks({
          maxTotal: remaining ?? undefined,
          stopBeforeIds: existingXIds.size ? existingXIds : undefined,
          skipExisting: existingXIds.size > 0,
        });
      }

      for (const b of globalNewBookmarks) existingXIds.add(b.id);
      bookmarks.push(...globalNewBookmarks);

      // Deduplicate by ID — folder-specific entries win (they have folderId).
      const bookmarkMap = new Map<string, (typeof bookmarks)[0]>();
      for (const b of bookmarks) {
        if (!bookmarkMap.has(b.id) || (b.folderId && !bookmarkMap.get(b.id)?.folderId)) {
          bookmarkMap.set(b.id, b);
        }
      }
      bookmarks = Array.from(bookmarkMap.values());

      await logProcessingEvent({
        runId: operation.id,
        type: "import",
        status: "completed",
        message: `X delta: ${bookmarks.length} new candidate(s) to store (${knownSkipped} already in library, not re-fetched).`,
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
      const alreadyHave = existingIds.has(bookmark.id);

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

      // X: never re-write known tweets (payload is immutable enough; re-fetch already avoided).
      // YT: still upsert so playlist metadata can refresh.
      if (alreadyHave && source === "x") {
        refreshed += 1;
        if (bookmark.folderId) {
          await prisma.bookmark.update({
            where: { id: bookmark.id },
            data: { folder: { connect: { id: bookmark.folderId } } },
          });
        }
        await logProcessingEvent({
          runId: operation.id,
          bookmarkId: bookmark.id,
          type: "import",
          status: "skipped",
          message: "Already in library — skipped re-import.",
          metadata: { source, folderId: bookmark.folderId ?? null },
        });
        continue;
      }

      if (alreadyHave) refreshed += 1;
      else created += 1;

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
        status: alreadyHave ? "skipped" : "completed",
        message: alreadyHave ? "Existing bookmark refreshed." : "New bookmark imported.",
        metadata: { source, folderId: bookmark.folderId ?? null },
      });
    }

    if (source === "x" && created > 0) {
      await incrementUsage(created, "x");
    }

    if (source === "x") {
      // Advance baseline only from the global feed's newest returned item.
      // Never set lastBookmarkId from a random folder tweet — that corrupts delta sync
      // and can hide newer bookmarks while still burning API credits on full folder scans.
      if (globalNewBookmarks.length > 0) {
        await updateSettings({
          lastBookmarkId: globalNewBookmarks[0].id,
          lastSyncedAt: new Date(),
        });
      } else {
        await updateSettings({ lastSyncedAt: new Date() });
      }
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
      notes:
        source === "x"
          ? `Imported ${created} new. Skipped re-fetch of known library tweets.`
          : `Imported ${created} new. Refreshed ${refreshed} existing.`,
      finish: true,
    });

    const xMessage =
      source !== "x"
        ? undefined
        : created > 0
          ? `Imported ${created} new X bookmark${created === 1 ? "" : "s"}. Already-known tweets were not re-fetched.`
          : settings.lastBookmarkId
            ? "No new X bookmarks since your last sync. Already-known tweets were not re-fetched (saves X API spend). If you are missing older items, reset the sync baseline in Settings."
            : "No X bookmarks returned.";

    return NextResponse.json({
      ok: true,
      source,
      imported: created,
      refreshed,
      fetched: bookmarks.length,
      runId: run.id,
      remaining: source === "x" && remaining !== null ? remaining - created : null,
      message: xMessage,
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
