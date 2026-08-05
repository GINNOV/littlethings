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

/**
 * Pending = still needs a real summary.
 * Category alone (e.g. stub "Other" with empty summary) does NOT count as done —
 * those used to zero-out the dashboard Pending tile while Enrich skipped them.
 */
export function pendingEnrichmentWhere() {
  return {
    OR: [{ summary: null }, { summary: "" }],
  };
}

/** Summarized = non-empty summary (strict complement of pending). */
export function summarizedEnrichmentWhere() {
  return {
    AND: [{ summary: { not: null } }, { NOT: { summary: "" } }],
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
  // Compose with AND so multiple OR groups (query, status=pending, video) never
  // overwrite each other via object-spread key collision.
  const clauses: Record<string, unknown>[] = [];
  if (p.query) {
    clauses.push({
      OR: [
        { text: { contains: p.query } },
        { summary: { contains: p.query } },
        { category: { contains: p.query } },
        { authorUsername: { contains: p.query } },
        { authorName: { contains: p.query } },
        { tags: { contains: p.query } },
      ],
    });
  }
  if (p.category) clauses.push({ category: p.category });
  if (p.folderId) clauses.push({ folderId: p.folderId });
  if (p.source) clauses.push({ source: p.source });
  const statusFilter = buildStatusFilter(p.status);
  if (Object.keys(statusFilter).length > 0) clauses.push(statusFilter);
  if (p.video) {
    clauses.push({
      OR: [{ source: "yt" }, ...videoUrls.map((u) => ({ externalUrls: { contains: u } }))],
    });
  }
  if (clauses.length === 0) return {};
  if (clauses.length === 1) return clauses[0];
  return { AND: clauses };
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

export type FilterCategory = { name: string; count: number };
export type FilterFolder = { id: string; name: string | null; count: number };
export type FilterCounts = {
  total: number;
  pending: number;
  summarized: number;
  uncategorized: number;
  noFolder: number;
  videos: number;
};

/** Facet options + counts for the library, scoped to optional source (x | yt). */
export async function getFilterOptions(source?: string) {
  const sourceWhere = source ? { source } : {};
  const videoUrls = ["/video/", "youtube.com", "youtu.be", "vimeo.com"];

  const [
    total,
    pending,
    summarized,
    uncategorized,
    noFolder,
    videos,
    categoryGroups,
    folderGroups,
    folders,
  ] = await Promise.all([
    prisma.bookmark.count({ where: sourceWhere }),
    prisma.bookmark.count({ where: { ...sourceWhere, ...pendingEnrichmentWhere() } }),
    prisma.bookmark.count({ where: { ...sourceWhere, ...summarizedEnrichmentWhere() } }),
    prisma.bookmark.count({
      where: {
        ...sourceWhere,
        OR: [{ category: null }, { category: "" }],
      },
    }),
    prisma.bookmark.count({ where: { ...sourceWhere, folderId: null } }),
    prisma.bookmark.count({
      where: {
        ...sourceWhere,
        OR: [{ source: "yt" }, ...videoUrls.map((u) => ({ externalUrls: { contains: u } }))],
      },
    }),
    prisma.bookmark.groupBy({
      by: ["category"],
      where: {
        ...sourceWhere,
        AND: [{ category: { not: null } }, { NOT: { category: "" } }],
      },
      _count: { _all: true },
      orderBy: { category: "asc" },
    }),
    prisma.bookmark.groupBy({
      by: ["folderId"],
      where: { ...sourceWhere, folderId: { not: null } },
      _count: { _all: true },
    }),
    prisma.bookmarkFolder.findMany({
      where: { bookmarks: { some: sourceWhere } },
      select: { id: true, name: true },
      orderBy: [{ name: "asc" }, { id: "asc" }],
    }),
  ]);

  const countByFolder = new Map(
    folderGroups.map((g) => [g.folderId as string, g._count._all])
  );

  const categories: FilterCategory[] = categoryGroups
    .filter((g): g is typeof g & { category: string } => !!g.category)
    .map((g) => ({ name: g.category, count: g._count._all }));

  const folderList: FilterFolder[] = folders.map((f) => ({
    id: f.id,
    name: f.name,
    count: countByFolder.get(f.id) ?? 0,
  }));

  const counts: FilterCounts = {
    total,
    pending,
    summarized,
    uncategorized,
    noFolder,
    videos,
  };

  return { categories, folders: folderList, counts };
}
