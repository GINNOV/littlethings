import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { fetchBookmarkFolders } from "@/lib/x";

export const dynamic = "force-dynamic";
export const maxDuration = 300;

export async function POST() {
  try {
    const folders = await fetchBookmarkFolders();

    for (const folder of folders) {
      await prisma.bookmarkFolder.upsert({
        where: { id: folder.id },
        update: { name: folder.name ?? null },
        create: { id: folder.id, name: folder.name ?? null },
      });
    }

    return NextResponse.json({ ok: true, total: folders.length });
  } catch (error) {
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : "Sync failed" },
      { status: 500 }
    );
  }
}
