import { NextResponse } from "next/server";
import { updateSettings } from "@/lib/settings";

export async function POST() {
  await updateSettings({
    lastBookmarkId: null,
  });

  return NextResponse.json({ ok: true, message: "Sync baseline reset. The next sync will fetch all bookmarks." });
}
