import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getSettings } from "@/lib/settings";
import { translateText } from "@/lib/llm";
import { createOperationRun, updateOperationRun } from "@/lib/processing";

export async function POST(request: Request) {
  const url = new URL(request.url);
  const bookmarkId = url.searchParams.get("bookmarkId");

  if (!bookmarkId) {
    return NextResponse.json({ ok: false, error: "Missing bookmarkId" }, { status: 400 });
  }

  const bookmark = await prisma.bookmark.findUnique({
    where: { id: bookmarkId },
  });

  if (!bookmark) {
    return NextResponse.json({ ok: false, error: "Bookmark not found" }, { status: 404 });
  }

  const settings = await getSettings();
  const targetLanguage = settings.targetLanguage || "English";

  const run = await createOperationRun({
    type: "translation",
    source: bookmark.source,
    total: 1,
    notes: `bookmark:${bookmark.id}`,
  });

  try {
    const translatedText = await translateText({
      text: bookmark.text || "",
      targetLanguage,
      processing: { runId: run.id, bookmarkId: bookmark.id },
    });

    await updateOperationRun(run.id, {
      status: "completed",
      processed: 1,
      updated: 1,
      finish: true,
    });

    return NextResponse.json({ ok: true, translatedText, runId: run.id });
  } catch (error) {
    await updateOperationRun(run.id, {
      status: "failed",
      processed: 1,
      failed: 1,
      notes: error instanceof Error ? error.message : "Translation failed",
      finish: true,
    });
    return NextResponse.json(
      { ok: false, error: error instanceof Error ? error.message : "Translation failed" },
      { status: 500 }
    );
  }
}
