import { NextResponse } from "next/server";
import { Prisma } from "@prisma/client";
import { z } from "zod";
import { getBookmarks, getFilterOptions } from "@/lib/bookmarks";
import { prisma } from "@/lib/db";

export const dynamic = "force-dynamic";

const dateValue = z.preprocess((value) => {
  if (value === null || value === undefined || value === "") return null;
  if (value instanceof Date) return value;
  if (typeof value === "string" || typeof value === "number") return new Date(value);
  return value;
}, z.date().nullable());

const nullableText = z.string().optional().nullable();
const sourceSchema = z.string().min(1).max(32).optional();

const bookmarkDataSchema = z.object({
  id: z.string().min(1).optional(),
  source: sourceSchema,
  tweetUrl: z.string().min(1).optional(),
  text: nullableText,
  authorName: nullableText,
  authorUsername: nullableText,
  createdAt: dateValue.optional(),
  likeCount: z.number().int().optional().nullable(),
  replyCount: z.number().int().optional().nullable(),
  retweetCount: z.number().int().optional().nullable(),
  quoteCount: z.number().int().optional().nullable(),
  lang: nullableText,
  externalUrls: z.union([z.string(), z.array(z.string())]).optional().nullable(),
  summary: nullableText,
  category: nullableText,
  tags: z.union([z.string(), z.array(z.string())]).optional().nullable(),
  rawJson: z.unknown().optional().nullable(),
  folderId: nullableText,
  folderName: nullableText,
  summarizedAt: dateValue.optional(),
  editedAt: dateValue.optional(),
  readAt: dateValue.optional(),
  mediaDescription: nullableText,
  mediaJson: z.unknown().optional().nullable(),
  enrichmentError: nullableText,
  enrichmentFailures: z.number().int().min(0).optional(),
}).strict();

const appendBookmarkDataSchema = z.object({
  summary: z.string().optional(),
  tags: z.union([z.string(), z.array(z.string())]).optional(),
  mediaDescription: z.string().optional(),
}).strict();

const postSchema = z.discriminatedUnion("action", [
  z.object({
    action: z.literal("upsertBookmark"),
    bookmark: bookmarkDataSchema.extend({
      id: z.string().min(1),
      tweetUrl: z.string().min(1),
    }),
  }).strict(),
  z.object({
    action: z.literal("updateBookmark"),
    bookmarkId: z.string().min(1),
    data: bookmarkDataSchema.omit({ id: true, folderName: true }).partial(),
  }).strict(),
  z.object({
    action: z.literal("appendBookmarkData"),
    bookmarkId: z.string().min(1),
    data: appendBookmarkDataSchema,
  }).strict(),
  z.object({
    action: z.literal("upsertFolder"),
    folder: z.object({
      id: z.string().min(1),
      name: nullableText,
    }).strict(),
  }).strict(),
]);

function errorResponse(error: unknown, status = 500) {
  return NextResponse.json(
    { ok: false, error: error instanceof Error ? error.message : String(error) },
    { status }
  );
}

function unauthorized(message: string) {
  return NextResponse.json({ ok: false, error: message }, { status: 401 });
}

function isLoopbackHost(host: string | null) {
  if (!host) return false;
  const hostname = host.startsWith("[")
    ? host.slice(0, host.indexOf("]") + 1).toLowerCase()
    : host.split(":")[0]?.toLowerCase();
  return hostname === "localhost" || hostname === "127.0.0.1" || hostname === "::1" || hostname === "[::1]";
}

function isAllowedRequest(request: Request) {
  const token = process.env.AGENT_API_TOKEN;
  if (token) {
    const authorization = request.headers.get("authorization");
    const headerToken = request.headers.get("x-agent-token");
    return authorization === `Bearer ${token}` || headerToken === token;
  }

  return isLoopbackHost(request.headers.get("host"));
}

function serializeUnknown(value: unknown) {
  if (value === undefined) return undefined;
  if (value === null) return null;
  return typeof value === "string" ? value : JSON.stringify(value);
}

function serializeStringList(value: string | string[] | null | undefined) {
  if (value === undefined) return undefined;
  if (value === null) return null;
  return Array.isArray(value) ? value.join(", ") : value;
}

function serializeExternalUrls(value: string | string[] | null | undefined) {
  if (value === undefined) return undefined;
  if (value === null) return null;
  return Array.isArray(value) ? JSON.stringify(value) : value;
}

async function ensureFolder(folderId?: string | null, folderName?: string | null) {
  if (!folderId) return;
  await prisma.bookmarkFolder.upsert({
    where: { id: folderId },
    update: { name: folderName ?? undefined },
    create: { id: folderId, name: folderName ?? null },
  });
}

function toBookmarkWriteData(
  input: z.infer<typeof bookmarkDataSchema>
): Partial<Prisma.BookmarkUncheckedCreateInput> {
  return {
    ...(input.source !== undefined ? { source: input.source } : {}),
    ...(input.tweetUrl !== undefined ? { tweetUrl: input.tweetUrl } : {}),
    ...(input.text !== undefined ? { text: input.text } : {}),
    ...(input.authorName !== undefined ? { authorName: input.authorName } : {}),
    ...(input.authorUsername !== undefined ? { authorUsername: input.authorUsername } : {}),
    ...(input.createdAt !== undefined ? { createdAt: input.createdAt } : {}),
    ...(input.likeCount !== undefined ? { likeCount: input.likeCount } : {}),
    ...(input.replyCount !== undefined ? { replyCount: input.replyCount } : {}),
    ...(input.retweetCount !== undefined ? { retweetCount: input.retweetCount } : {}),
    ...(input.quoteCount !== undefined ? { quoteCount: input.quoteCount } : {}),
    ...(input.lang !== undefined ? { lang: input.lang } : {}),
    ...(input.externalUrls !== undefined ? { externalUrls: serializeExternalUrls(input.externalUrls) } : {}),
    ...(input.summary !== undefined ? { summary: input.summary } : {}),
    ...(input.category !== undefined ? { category: input.category } : {}),
    ...(input.tags !== undefined ? { tags: serializeStringList(input.tags) } : {}),
    ...(input.rawJson !== undefined ? { rawJson: serializeUnknown(input.rawJson) } : {}),
    ...(input.folderId !== undefined ? { folderId: input.folderId } : {}),
    ...(input.summarizedAt !== undefined ? { summarizedAt: input.summarizedAt } : {}),
    ...(input.editedAt !== undefined ? { editedAt: input.editedAt } : {}),
    ...(input.readAt !== undefined ? { readAt: input.readAt } : {}),
    ...(input.mediaDescription !== undefined ? { mediaDescription: input.mediaDescription } : {}),
    ...(input.mediaJson !== undefined ? { mediaJson: serializeUnknown(input.mediaJson) } : {}),
    ...(input.enrichmentError !== undefined ? { enrichmentError: input.enrichmentError } : {}),
    ...(input.enrichmentFailures !== undefined ? { enrichmentFailures: input.enrichmentFailures } : {}),
  };
}

function appendText(existing: string | null, next?: string) {
  if (!next?.trim()) return existing;
  return existing?.trim() ? `${existing.trim()}\n\n${next.trim()}` : next.trim();
}

function appendTags(existing: string | null, next?: string | string[]) {
  if (!next) return existing;
  const current = existing?.split(",").map((tag) => tag.trim()).filter(Boolean) ?? [];
  const incoming = (Array.isArray(next) ? next : next.split(",")).map((tag) => tag.trim()).filter(Boolean);
  return Array.from(new Set([...current, ...incoming])).join(", ") || null;
}

async function handleGet(request: Request) {
  const url = new URL(request.url);
  const resource = url.searchParams.get("resource") ?? "help";

  if (resource === "help") {
    return NextResponse.json({
      ok: true,
      endpoint: "/api/agent",
      auth: process.env.AGENT_API_TOKEN
        ? "Send Authorization: Bearer <AGENT_API_TOKEN> or x-agent-token."
        : "Allowed from localhost. Set AGENT_API_TOKEN to require a token.",
      reads: [
        "GET ?resource=bookmarks&q=&source=&status=&category=&folderId=&page=&pageSize=&semantic=true",
        "GET ?resource=bookmark&id=<bookmarkId>",
        "GET ?resource=folders",
        "GET ?resource=runs&source=&status=&type=&take=",
      ],
      writes: [
        "POST { action: \"upsertBookmark\", bookmark: { id, tweetUrl, ... } }",
        "POST { action: \"updateBookmark\", bookmarkId, data: { summary, category, tags, readAt, ... } }",
        "POST { action: \"appendBookmarkData\", bookmarkId, data: { summary, tags, mediaDescription } }",
        "POST { action: \"upsertFolder\", folder: { id, name } }",
      ],
    });
  }

  if (resource === "bookmarks") {
    const page = Math.max(1, Number(url.searchParams.get("page") ?? 1));
    const pageSize = Math.min(200, Math.max(1, Number(url.searchParams.get("pageSize") ?? 50)));
    const data = await getBookmarks({
      query: url.searchParams.get("q") ?? "",
      category: url.searchParams.get("category") ?? "",
      folderId: url.searchParams.get("folderId") ?? "",
      source: url.searchParams.get("source") ?? "",
      status: url.searchParams.get("status") ?? "",
      video: url.searchParams.get("video") === "true",
      semantic: url.searchParams.get("semantic") === "true",
      page,
      pageSize,
    });
    return NextResponse.json({ ok: true, page, pageSize, ...data });
  }

  if (resource === "bookmark") {
    const id = url.searchParams.get("id");
    if (!id) return errorResponse("Missing id", 400);
    const bookmark = await prisma.bookmark.findUnique({ where: { id }, include: { folder: true } });
    if (!bookmark) return errorResponse("Bookmark not found", 404);
    return NextResponse.json({ ok: true, bookmark });
  }

  if (resource === "folders") {
    const source = url.searchParams.get("source") ?? undefined;
    const filters = await getFilterOptions(source);
    return NextResponse.json({ ok: true, folders: filters.folders });
  }

  if (resource === "runs") {
    const take = Math.min(200, Math.max(1, Number(url.searchParams.get("take") ?? 50)));
    const runs = await prisma.operationRun.findMany({
      where: {
        ...(url.searchParams.get("source") ? { source: url.searchParams.get("source")! } : {}),
        ...(url.searchParams.get("status") ? { status: url.searchParams.get("status")! } : {}),
        ...(url.searchParams.get("type") ? { type: url.searchParams.get("type")! } : {}),
      },
      orderBy: { startedAt: "desc" },
      take,
      include: { _count: { select: { events: true, llmRequests: true } } },
    });
    return NextResponse.json({ ok: true, runs });
  }

  return errorResponse(`Unsupported resource: ${resource}`, 400);
}

async function handlePost(request: Request) {
  const body = await request.json();
  const parsed = postSchema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json({ ok: false, error: parsed.error.flatten() }, { status: 400 });
  }

  if (parsed.data.action === "upsertBookmark") {
    await ensureFolder(parsed.data.bookmark.folderId, parsed.data.bookmark.folderName);
    const data = toBookmarkWriteData(parsed.data.bookmark);
    const bookmark = await prisma.bookmark.upsert({
      where: { id: parsed.data.bookmark.id },
      update: data,
      create: {
        id: parsed.data.bookmark.id,
        source: parsed.data.bookmark.source ?? "agent",
        tweetUrl: parsed.data.bookmark.tweetUrl,
        ...data,
      },
    });
    return NextResponse.json({ ok: true, bookmark });
  }

  if (parsed.data.action === "updateBookmark") {
    await ensureFolder(parsed.data.data.folderId);
    const data = toBookmarkWriteData(parsed.data.data);
    const bookmark = await prisma.bookmark.update({
      where: { id: parsed.data.bookmarkId },
      data: { ...data, editedAt: new Date() },
    });
    return NextResponse.json({ ok: true, bookmark });
  }

  if (parsed.data.action === "appendBookmarkData") {
    const existing = await prisma.bookmark.findUnique({ where: { id: parsed.data.bookmarkId } });
    if (!existing) return errorResponse("Bookmark not found", 404);
    const bookmark = await prisma.bookmark.update({
      where: { id: parsed.data.bookmarkId },
      data: {
        summary: appendText(existing.summary, parsed.data.data.summary),
        tags: appendTags(existing.tags, parsed.data.data.tags),
        mediaDescription: appendText(existing.mediaDescription, parsed.data.data.mediaDescription),
        editedAt: new Date(),
      },
    });
    return NextResponse.json({ ok: true, bookmark });
  }

  const folder = await prisma.bookmarkFolder.upsert({
    where: { id: parsed.data.folder.id },
    update: { name: parsed.data.folder.name ?? null },
    create: { id: parsed.data.folder.id, name: parsed.data.folder.name ?? null },
  });
  return NextResponse.json({ ok: true, folder });
}

export async function GET(request: Request) {
  if (!isAllowedRequest(request)) {
    return unauthorized("Agent API is local-only unless AGENT_API_TOKEN is configured and supplied.");
  }

  try {
    return await handleGet(request);
  } catch (error) {
    return errorResponse(error);
  }
}

export async function POST(request: Request) {
  if (!isAllowedRequest(request)) {
    return unauthorized("Agent API is local-only unless AGENT_API_TOKEN is configured and supplied.");
  }

  try {
    return await handlePost(request);
  } catch (error) {
    return errorResponse(error);
  }
}
