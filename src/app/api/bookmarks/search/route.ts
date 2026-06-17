import { NextResponse } from "next/server";
import { searchBookmarksSemantically } from "@/lib/bookmarks";

export async function GET(request: Request) {
  const url = new URL(request.url);
  const query = url.searchParams.get("q");

  if (!query) {
    return NextResponse.json({ ok: false, error: "Missing query" }, { status: 400 });
  }

  try {
    const sorted = await searchBookmarksSemantically(query);
    return NextResponse.json({ ok: true, bookmarks: sorted });
  } catch (error) {
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : "Search failed" },
      { status: 500 }
    );
  }
}
