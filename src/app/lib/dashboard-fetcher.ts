import { prisma } from "@/lib/db";
import { AppSettings, getUsageMonth } from "@/lib/settings";
import { fetchXUsage } from "@/lib/x";

type UsageMonth = Awaited<ReturnType<typeof getUsageMonth>>;
type LiveXUsage = NonNullable<Awaited<ReturnType<typeof fetchXUsage>>>;

export async function getDashboardStats(tab: "x" | "yt") {
  const [total, summarized, usage, settings, lastRun, recentRuns, metrics] = await Promise.all([
    prisma.bookmark.count({ where: { source: tab } }),
    prisma.bookmark.count({ where: { source: tab, summary: { not: null } } }),
    getUsageMonth(new Date(), tab),
    prisma.settings.findUnique({ where: { id: "default" } }),
    prisma.importRun.findFirst({ orderBy: { startedAt: "desc" } }),
    prisma.operationRun.findMany({ where: { source: tab }, orderBy: { startedAt: "desc" }, take: 5 }),
    prisma.operationRun.aggregate({
      where: { source: tab },
      _sum: { failed: true, skipped: true, updated: true },
    }),
  ]);

  const pending = await prisma.bookmark.count({
    where: { 
      source: tab, 
      AND: [
        { OR: [{ summary: null }, { summary: "" }] },
        { OR: [{ category: null }, { category: "" }] }
      ]
    },
  });

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
    total, summarized, usage, settings, lastRun, pending, recent,
    operationRuns: recentRuns,
    failedItemsCount: metrics._sum.failed ?? 0,
    skippedItemsCount: metrics._sum.skipped ?? 0
  };
}

function mapLiveStats(live: LiveXUsage) {
  const d = live.data;
  return {
    usedCount: Number(d.tweet_count || 0), cap: Number(d.cap_per_month || 0),
    balance: typeof d.balance === 'number' ? d.balance.toFixed(2) : (d.balance ?? null),
    liveXUsage: live, costPerCall: d.cost_per_unit ?? null
  };
}

export async function getLiveXStats(tab: "x" | "yt", internalUsage: UsageMonth, settings: AppSettings | null) {
  if (tab !== "x") return { usedCount: internalUsage.usedBookmarks, cap: settings?.ytMonthlyCap ?? 100, balance: null, liveXUsage: null, costPerCall: null };
  try {
    const live = await fetchXUsage();
    return live ? mapLiveStats(live) : { usedCount: internalUsage.usedBookmarks, cap: settings?.monthlyCap ?? 100, balance: null, liveXUsage: null, costPerCall: null };
  } catch {
    return { usedCount: internalUsage.usedBookmarks, cap: settings?.monthlyCap ?? 100, balance: null, liveXUsage: null, costPerCall: null };
  }
}
