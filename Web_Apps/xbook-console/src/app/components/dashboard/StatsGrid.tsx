import { AccountStats } from "./AccountStats";
import { SyncCard } from "./SyncCard";
import { EnrichmentSummary } from "./EnrichmentSummary";

type Props = {
  tab: "x" | "yt"; total: number; summarized: number; pending: number;
  usedCount: number; cap: number; balance: string | null;
  liveXUsage: unknown; costPerCall: number | null;
  enrichBatchSize: number; lastSync: Date | string | null;
  failedRunsCount: number;
  skippedItemsCount: number;
  settings: { soundOnComplete: boolean | null; soundOnError: boolean | null; } | null;
};

export function StatsGrid({ tab, total, summarized, pending, usedCount, cap, balance, liveXUsage, costPerCall, enrichBatchSize, lastSync, failedRunsCount, skippedItemsCount, settings }: Props) {
  return (
    <section className="grid gap-6 lg:grid-cols-3">
      <AccountStats tab={tab} used={usedCount} cap={cap} bal={balance} live={!!liveXUsage} cost={costPerCall} sum={summarized} pend={pending} total={total} />
      <SyncCard tab={tab} enrichSize={enrichBatchSize} pend={pending} total={total} last={lastSync} settings={settings} />
      <EnrichmentSummary sum={summarized} pend={pending} failed={failedRunsCount} skipped={skippedItemsCount} />
    </section>
  );
}
