import { NextResponse } from "next/server";
import { z } from "zod";
import { prisma } from "@/lib/db";

const schema = z.object({
  bookmarkId: z.string().min(1),
  read: z.boolean(),
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

  const { bookmarkId, read } = parsed.data;
  const updated = await prisma.bookmark.update({
    where: { id: bookmarkId },
    data: {
      readAt: read ? new Date() : null,
    },
  });

  return NextResponse.json({ ok: true, bookmark: updated });
}
