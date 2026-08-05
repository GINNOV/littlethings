import { AccountStats } from "./AccountStats";
import { SyncCard } from "./SyncCard";
import { EnrichmentSummary } from "./EnrichmentSummary";

type Props = {
  tab: "x" | "yt";
  total: number;
  summarized: number;
  pending: number;
  usedCount: number;
  cap: number;
  balance: string | null;
  liveXUsage: unknown;
  costPerCall: number | null;
  usageSource?: "live" | "local";
  enrichBatchSize: number;
  lastSync: Date | string | null;
  /** Current bookmarks with enrichmentError set */
  failedCount: number;
  /** Pending bookmarks with enrichmentFailures ≥ 3 (auto-enrich skips them) */
  blockedCount: number;
  indexedCount?: number;
  unindexedCount?: number;
  settings: { soundOnComplete: boolean | null; soundOnError: boolean | null } | null;
};

export function StatsGrid({
  tab,
  total,
  summarized,
  pending,
  usedCount,
  cap,
  balance,
  liveXUsage,
  costPerCall,
  usageSource = "local",
  enrichBatchSize,
  lastSync,
  failedCount,
  blockedCount,
  indexedCount = 0,
  unindexedCount = 0,
  settings,
}: Props) {
  return (
    <section className="grid gap-6 lg:grid-cols-3">
      <AccountStats
        tab={tab}
        used={usedCount}
        cap={cap}
        bal={balance}
        live={!!liveXUsage}
        cost={costPerCall}
        usageSource={usageSource}
        sum={summarized}
        pend={pending}
        total={total}
      />
      <SyncCard
        tab={tab}
        enrichSize={enrichBatchSize}
        pend={pending}
        total={total}
        last={lastSync}
        settings={settings}
      />
      <EnrichmentSummary
        source={tab}
        sum={summarized}
        pend={pending}
        failed={failedCount}
        skipped={blockedCount}
        indexed={indexedCount}
        unindexed={unindexedCount}
        soundOnComplete={settings?.soundOnComplete ?? false}
        soundOnError={settings?.soundOnError ?? false}
      />
    </section>
  );
}
