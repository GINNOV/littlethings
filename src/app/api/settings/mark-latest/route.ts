import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { updateSettings } from "@/lib/settings";

export async function POST() {
  const latest = await prisma.bookmark.findFirst({
    where: { source: "x" },
    orderBy: { importedAt: "desc" },
  });

  if (!latest) {
    return NextResponse.json({ ok: false, error: "No bookmarks found." }, { status: 400 });
  }

  await updateSettings({
    lastBookmarkId: latest.id,
    lastSyncedAt: new Date(),
  });

  return NextResponse.json({ ok: true, lastBookmarkId: latest.id });
}
