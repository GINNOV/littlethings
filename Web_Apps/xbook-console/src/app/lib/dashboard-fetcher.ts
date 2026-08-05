import { prisma } from "@/lib/db";
import {
  blockedEnrichmentWhere,
  failedEnrichmentWhere,
  needsEmbeddingWhere,
  pendingEnrichmentWhere,
  summarizedEnrichmentWhere,
} from "@/lib/bookmarks";
import { AppSettings, getUsageMonth } from "@/lib/settings";
import { fetchXUsage } from "@/lib/x";

type UsageMonth = Awaited<ReturnType<typeof getUsageMonth>>;
type LiveXUsage = NonNullable<Awaited<ReturnType<typeof fetchXUsage>>>;

export async function getDashboardStats(tab: "x" | "yt") {
  const sourceWhere = { source: tab };
  const [
    total,
    summarized,
    pending,
    failed,
    blocked,
    usage,
    settings,
    lastRun,
    recentRuns,
    withEmbedding,
    unindexed,
  ] = await Promise.all([
    prisma.bookmark.count({ where: sourceWhere }),
    // Match bookmarks list status filters so summarized + pending = total
    prisma.bookmark.count({ where: { ...sourceWhere, ...summarizedEnrichmentWhere() } }),
    prisma.bookmark.count({ where: { ...sourceWhere, ...pendingEnrichmentWhere() } }),
    // Current library state — not lifetime operation-run counters
    prisma.bookmark.count({ where: { ...sourceWhere, ...failedEnrichmentWhere() } }),
    prisma.bookmark.count({ where: { ...sourceWhere, ...blockedEnrichmentWhere() } }),
    getUsageMonth(new Date(), tab),
    prisma.settings.findUnique({ where: { id: "default" } }),
    prisma.importRun.findFirst({ orderBy: { startedAt: "desc" } }),
    prisma.operationRun.findMany({ where: { source: tab }, orderBy: { startedAt: "desc" }, take: 5 }),
    // Indexed = has an embedding vector (searchable for this tab).
    prisma.bookmark.count({
      where: { source: tab, embedding: { not: null } },
    }),
    // Missing = same set the embedding sync endpoint will process for this tab.
    prisma.bookmark.count({
      where: needsEmbeddingWhere(tab),
    }),
  ]);

  const recent = await prisma.bookmark.findMany({
    where: {
      OR: [
        { source: tab },
        { source: { notIn: ["x", "yt"] } },
      ],
    },
    include: { folder: true },
    orderBy: { importedAt: "desc" },
    take: 20,
  });

  return {
    total,
    summarized,
    usage,
    settings,
    lastRun,
    pending,
    recent,
    operationRuns: recentRuns,
    /** Bookmarks with a current enrichmentError (not historical run sums). */
    failedItemsCount: failed,
    /** Pending items exhausted of auto-retries (enrichmentFailures ≥ 3). */
    skippedItemsCount: blocked,
    indexHealth: { withEmbedding, unindexed },
  };
}

function mapLiveStats(live: LiveXUsage) {
  const d = live.data;
  const used = Number(d.tweet_count ?? NaN);
  const cap = Number(d.cap_per_month ?? NaN);
  const hasBalance = d.balance != null && d.balance !== "";
  // Only treat the response as live when it has usable usage or prepaid data
  if (hasBalance) {
    return {
      usedCount: Number.isFinite(used) ? used : 0,
      cap: Number.isFinite(cap) && cap > 0 ? cap : 0,
      balance: typeof d.balance === "number" ? d.balance.toFixed(2) : String(d.balance),
      liveXUsage: live,
      costPerCall: d.cost_per_unit ?? null,
      usageSource: "live" as const,
    };
  }
  if (!Number.isFinite(used) || !Number.isFinite(cap) || cap <= 0) return null;
  return {
    usedCount: used,
    cap,
    balance: null as string | null,
    liveXUsage: live,
    costPerCall: d.cost_per_unit ?? null,
    usageSource: "live" as const,
  };
}

function localImportStats(tab: "x" | "yt", internalUsage: UsageMonth, settings: AppSettings | null) {
  return {
    usedCount: internalUsage.usedBookmarks,
    cap: tab === "yt" ? (settings?.ytMonthlyCap ?? 100) : (settings?.monthlyCap ?? 100),
    balance: null as string | null,
    liveXUsage: null,
    costPerCall: null as number | null,
    usageSource: "local" as const,
  };
}

export async function getLiveXStats(tab: "x" | "yt", internalUsage: UsageMonth, settings: AppSettings | null) {
  if (tab !== "x") return localImportStats(tab, internalUsage, settings);
  try {
    const live = await fetchXUsage();
    if (live) {
      const mapped = mapLiveStats(live);
      if (mapped) return mapped;
    }
  } catch {
    // Fall through to local import counter
  }
  return localImportStats(tab, internalUsage, settings);
}
