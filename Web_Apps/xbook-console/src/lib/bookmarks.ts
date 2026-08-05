import { prisma } from "./db";
import { generateEmbedding } from "./llm";

export type BookmarkItem = {
  id: string; source: string; tweetUrl: string; text: string | null; folderName: string | null; summary: string | null;
  category: string | null; tags: string | null; authorUsername: string | null; importedAt: string | null;
  createdAt: string | null; summarizedAt: string | null; editedAt: string | null; readAt: string | null;
  error: string | null; folder?: { name: string | null } | null; similarity?: number;
};

export function cosineSimilarity(vecA: number[], vecB: number[]) {
  let dot = 0, nA = 0, nB = 0;
  for (let i = 0; i < vecA.length; i++) { dot += vecA[i] * vecB[i]; nA += vecA[i] * vecA[i]; nB += vecB[i] * vecB[i]; }
  return dot / (Math.sqrt(nA) * Math.sqrt(nB));
}

export async function searchBookmarksSemantically(query: string) {
  const qe = await generateEmbedding(query);
  const bs = await prisma.bookmark.findMany({ where: { embedding: { not: null } }, select: { id: true, embedding: true } });
  const results = bs.map(b => ({ id: b.id, similarity: cosineSimilarity(qe, Array.from(new Float32Array(b.embedding!.buffer))) })).sort((a, b) => b.similarity - a.similarity).slice(0, 50);
  const full = await prisma.bookmark.findMany({ where: { id: { in: results.map(r => r.id) } }, include: { folder: true } });
  return results.map(r => { const f = full.find(fb => fb.id === r.id); return f ? { ...f, similarity: r.similarity } : null; }).filter((b): b is NonNullable<typeof b> => !!b);
}

/** Pending = no usable enrichment yet (empty summary AND empty category). */
export function pendingEnrichmentWhere() {
  return {
    AND: [
      { OR: [{ summary: null }, { summary: "" }] },
      { OR: [{ category: null }, { category: "" }] },
    ],
  };
}

/** Summarized = has a non-empty summary or category (complement of pending). */
export function summarizedEnrichmentWhere() {
  return {
    OR: [{ summary: { not: "" } }, { category: { not: "" } }],
  };
}

/** Current enrichment failures: last attempt left a non-empty error on the bookmark. */
export function failedEnrichmentWhere() {
  return {
    AND: [{ enrichmentError: { not: null } }, { NOT: { enrichmentError: "" } }],
  };
}

/**
 * Blocked from automatic enrich: still pending and has exhausted the default retry budget
 * (see enrich route: enrichmentFailures < 3 unless full/reprocess).
 */
export function blockedEnrichmentWhere() {
  return {
    ...pendingEnrichmentWhere(),
    enrichmentFailures: { gte: 3 },
  };
}

/**
 * Bookmarks that can be (re)indexed: non-empty summary and no embedding yet.
 * Dashboard "missing" and POST /api/bookmarks/embeddings/sync must use the same predicate.
 */
export function needsEmbeddingWhere(source?: "x" | "yt" | string | null) {
  return {
    ...(source ? { source } : {}),
    embedding: null,
    AND: [{ summary: { not: null } }, { NOT: { summary: "" } }],
  };
}

function buildStatusFilter(status?: string) {
  if (status === "pending") return pendingEnrichmentWhere();
  if (status === "summarized") return summarizedEnrichmentWhere();
  return {};
}

function buildWhereClause(p: any) {
  const videoUrls = ["/video/", "youtube.com", "youtu.be", "vimeo.com"];
  return {
    ...(p.query ? { 
      OR: [
        { text: { contains: p.query } }, 
        { summary: { contains: p.query } }, 
        { category: { contains: p.query } }, 
        { authorUsername: { contains: p.query } },
        { authorName: { contains: p.query } },
        { tags: { contains: p.query } }
      ] 
    } : {}),
    ...(p.category ? { category: p.category } : {}),
    ...(p.folderId ? { folderId: p.folderId } : {}),
    ...(p.source ? { source: p.source } : {}),
    ...buildStatusFilter(p.status),
    ...(p.video ? { OR: [{ source: "yt" }, ...videoUrls.map(u => ({ externalUrls: { contains: u } }))] } : {}),
  };
}

const mapB = (b: any) => ({
  ...b, folderName: b.folder?.name ?? null, importedAt: b.importedAt?.toISOString() ?? null,
  createdAt: b.createdAt?.toISOString() ?? null, summarizedAt: b.summarizedAt?.toISOString() ?? null,
  editedAt: b.editedAt?.toISOString() ?? null, readAt: b.readAt?.toISOString() ?? null,
  // Prefer durable bookmark field; fall back to latest failed processing event.
  error: b.enrichmentError || b.processingEvents?.[0]?.message || null,
});

export async function getBookmarks(p: any) {
  if (p.semantic && p.query) return performSemanticSearch(p.query, p.page, p.pageSize);
  const where = buildWhereClause(p);
  const total = await prisma.bookmark.count({ where });
  const raw = await prisma.bookmark.findMany({
    where, include: { folder: true, processingEvents: { where: { status: "failed" }, orderBy: { createdAt: "desc" }, take: 1, select: { message: true } } },
    orderBy: [{ category: "asc" }, { importedAt: "desc" }], skip: (p.page - 1) * p.pageSize, take: p.pageSize,
  });
  return { bookmarks: raw.map(mapB), total };
}

async function performSemanticSearch(query: string, page: number, pageSize: number) {
  const all = await searchBookmarksSemantically(query);
  const skip = (page - 1) * pageSize;
  return { bookmarks: all.slice(skip, skip + pageSize).map(mapB), total: all.length };
}

export async function getFilterOptions(source?: string) {
  const [cr, fs] = await Promise.all([
    prisma.bookmark.findMany({ select: { category: true }, where: { category: { not: null } } }),
    prisma.bookmarkFolder.findMany({ where: { bookmarks: { some: source ? { source } : {} } }, select: { id: true, name: true }, orderBy: [{ name: "asc" }, { id: "asc" }] })
  ]);
  const categories = Array.from(new Set(cr.map(i => i.category).filter(Boolean))).sort((a, b) => a!.localeCompare(b!));
  return { categories, folders: fs };
}
