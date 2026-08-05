import { DashboardHeader } from "./components/dashboard/DashboardHeader";
import { StatsGrid } from "./components/dashboard/StatsGrid";
import { RecentActivity } from "./components/dashboard/RecentActivity";
import { RecentImports } from "./components/dashboard/RecentImports";
import { formatDateShort, getYouTubeTitle, getYouTubeFolder } from "./lib/dashboard";
import { getDashboardStats, getLiveXStats } from "./lib/dashboard-fetcher";

export default async function Home({ searchParams }: { searchParams?: Promise<Record<string, string | string[] | undefined>> }) {
  const p = await searchParams;
  const tab: "x" | "yt" = p?.tab === "yt" ? "yt" : "x";

  const stats = await getDashboardStats(tab);
  const live = await getLiveXStats(tab, stats.usage, stats.settings);
  const lastSync = stats.lastRun?.finishedAt ?? stats.lastRun?.startedAt ?? null;

  return (
    <main className="min-h-screen bg-surface-container-low px-4 py-6 lg:px-8 lg:py-8">
      <div className="mx-auto flex max-w-[1500px] flex-col gap-8">
        <DashboardHeader tab={tab} />
        <StatsGrid
          tab={tab}
          total={stats.total}
          summarized={stats.summarized}
          pending={stats.pending}
          usedCount={live.usedCount}
          cap={live.cap}
          balance={live.balance}
          liveXUsage={live.liveXUsage}
          costPerCall={live.costPerCall}
          usageSource={live.usageSource}
          enrichBatchSize={stats.settings?.enrichBatchSize ?? 50}
          lastSync={lastSync}
          failedCount={stats.failedItemsCount}
          blockedCount={stats.skippedItemsCount}
          indexedCount={stats.indexHealth?.withEmbedding ?? 0}
          unindexedCount={stats.indexHealth?.unindexed ?? 0}
          settings={stats.settings}
        />
        <RecentActivity operationRuns={stats.operationRuns} />
        <RecentImports tab={tab} recent={stats.recent} getYouTubeTitle={getYouTubeTitle} 
          getYouTubeFolder={getYouTubeFolder} formatDateShort={formatDateShort} />
      </div>
    </main>
  );
}
