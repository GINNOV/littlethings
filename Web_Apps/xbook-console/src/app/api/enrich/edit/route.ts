import { NextResponse } from "next/server";
import { z } from "zod";
import { prisma } from "@/lib/db";

const schema = z.object({
  bookmarkId: z.string().min(1),
  summary: z.string().optional().nullable(),
  category: z.string().optional().nullable(),
  tags: z.string().optional().nullable(),
});

export async function POST(request: Request) {
  const body = await request.json();
  const parsed = schema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json(
      { ok: false, error: parsed.error.flatten() },
      { status: 400 }
    );
  }

  const { bookmarkId, summary, category, tags } = parsed.data;
  const updated = await prisma.bookmark.update({
    where: { id: bookmarkId },
    data: {
      summary: summary?.trim() ? summary : null,
      category: category?.trim() ? category : null,
      tags: tags?.trim() ? tags : null,
      summarizedAt: new Date(),
      editedAt: new Date(),
    },
  });

  return NextResponse.json({ ok: true, bookmark: updated });
}
