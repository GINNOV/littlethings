import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { fetchYouTubePlaylists } from "@/lib/youtube";

export const dynamic = "force-dynamic";
export const maxDuration = 300;

export async function POST() {
  try {
    const playlists = await fetchYouTubePlaylists();

    for (const playlist of playlists) {
      const folderId = `yt:pl:${playlist.id}`;
      await prisma.bookmarkFolder.upsert({
        where: { id: folderId },
        update: { name: playlist.title ?? null },
        create: {
          id: folderId,
          name: playlist.title ?? null,
        },
      });
    }

    return NextResponse.json({
      ok: true,
      total: playlists.length,
    });
  } catch (error) {
    const status =
      (error as Error & { code?: string })?.code === "YOUTUBE_QUOTA" ? 429 : 500;
    return NextResponse.json(
      {
        ok: false,
        error: error instanceof Error ? error.message : "YouTube playlist sync failed",
      },
      { status }
    );
  }
}
