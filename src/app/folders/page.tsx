import Link from "next/link";
import FoldersPanel from "@/app/components/FoldersPanel";
import YouTubeFoldersPanel from "@/app/components/YouTubeFoldersPanel";
import { prisma } from "@/lib/db";
import { fetchYouTubePlaylists } from "@/lib/youtube";
import { getSettings } from "@/lib/settings";

export const dynamic = "force-dynamic";

type PageProps = {
  searchParams?: Record<string, string | string[] | undefined>;
};

export default async function FoldersPage({ searchParams }: PageProps) {
  const resolvedParams = await searchParams;
  const tab = resolvedParams?.tab === "yt" ? "yt" : "x";
  const settings = await getSettings();
  
  const folders = await prisma.bookmarkFolder.findMany({
    where: { id: { not: { startsWith: "yt:pl:" } } },
    include: { _count: { select: { bookmarks: true } } },
    orderBy: { name: "asc" },
  });
  const ytFolders = await prisma.$queryRaw<
    Array<{ id: string; name: string | null; total: number | string }>
  >`
    SELECT
      bf.id AS id,
      bf.name AS name,
      COALESCE(cnt.total, 0) AS total
    FROM BookmarkFolder bf
    LEFT JOIN (
      SELECT
        COALESCE(folderId, 'yt:pl:' || json_extract(rawJson, '$.playlistId')) AS playlistKey,
        COUNT(*) AS total
      FROM Bookmark
      WHERE source = 'yt'
      GROUP BY COALESCE(folderId, 'yt:pl:' || json_extract(rawJson, '$.playlistId'))
    ) cnt ON cnt.playlistKey = bf.id
    WHERE bf.id LIKE 'yt:pl:%'
    ORDER BY bf.name ASC
  `;
  let ytLivePlaylists: Awaited<ReturnType<typeof fetchYouTubePlaylists>> | null = null;
  if (tab === "yt") {
    try {
      ytLivePlaylists = await fetchYouTubePlaylists();
    } catch {
      ytLivePlaylists = null;
    }
  }

  return (
    <main className="min-h-screen bg-surface-container-low px-4 py-6 lg:px-8 lg:py-8">
      <div className="mx-auto flex max-w-[1400px] flex-col gap-6">
        <header>
          <h1 className="font-headline text-5xl font-semibold tracking-tight">
            Folder Management
          </h1>
          <p className="mt-3 max-w-3xl text-sm text-on-surface-variant">
            Configure and monitor bookmark ingestion sources. Folder imports skip existing
            items and continue fetching missing ones until the end or your monthly cap.
          </p>
        </header>

        <nav className="inline-flex w-fit rounded-lg bg-surface-container-high p-1">
          <Link
            href="/folders?tab=x"
            className={`rounded-md px-5 py-2 text-sm font-semibold ${
              tab === "x" ? "bg-surface-container-lowest text-on-surface" : "text-on-surface-variant"
            }`}
          >
            X folders
          </Link>
          <Link
            href="/folders?tab=yt"
            className={`rounded-md px-5 py-2 text-sm font-semibold ${
              tab === "yt" ? "bg-surface-container-lowest text-on-surface" : "text-on-surface-variant"
            }`}
          >
            YouTube playlists
          </Link>
        </nav>

        <section className="rounded-lg bg-surface-container-lowest p-4">
          {tab === "x" ? (
            <FoldersPanel
              folders={folders.map((folder) => ({
                id: folder.id,
                name: folder.name,
                total: folder._count.bookmarks,
              }))}
              soundOnComplete={settings?.soundOnComplete ?? false}
              soundOnError={settings?.soundOnError ?? false}
            />
          ) : (
            <YouTubeFoldersPanel
              folders={
                ytLivePlaylists
                  ? ytLivePlaylists.map((playlist) => ({
                      id: `yt:pl:${playlist.id}`,
                      name: playlist.title ?? null,
                      total: playlist.itemCount ?? 0,
                    }))
                  : ytFolders.map((folder) => ({
                      id: folder.id,
                      name: folder.name,
                      total: Number(folder.total),
                    }))
              }
              soundOnComplete={settings?.soundOnComplete ?? false}
              soundOnError={settings?.soundOnError ?? false}
            />
          )}
        </section>
      </div>
    </main>
  );
}
