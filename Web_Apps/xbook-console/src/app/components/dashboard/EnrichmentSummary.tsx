"use client";

import { useEffect, useState } from "react";
import { useActions } from "../../hooks/useActions";

type Props = {
  source: "x" | "yt";
  sum: number;
  pend: number;
  failed: number;
  skipped: number;
  indexed?: number;
  unindexed?: number;
  soundOnComplete?: boolean;
  soundOnError?: boolean;
};

function fmt(n: number) {
  return n.toLocaleString();
}

export function EnrichmentSummary({
  source,
  sum,
  pend,
  failed,
  skipped,
  indexed = 0,
  unindexed = 0,
  soundOnComplete = false,
  soundOnError = false,
}: Props) {
  const { loading, message, runSyncEmbeddings } = useActions(
    source,
    50,
    soundOnComplete,
    soundOnError
  );
  const syncing = loading.embeddings;

  // Live counters while syncing so "missing" and "done" stay consistent.
  const [liveIndexed, setLiveIndexed] = useState(indexed);
  const [liveUnindexed, setLiveUnindexed] = useState(unindexed);

  useEffect(() => {
    if (!syncing) {
      setLiveIndexed(indexed);
      setLiveUnindexed(unindexed);
    }
  }, [indexed, unindexed, syncing]);

  const indexable = liveIndexed + liveUnindexed;
  const coverage = indexable > 0 ? Math.min(100, (liveIndexed / indexable) * 100) : 0;
  const needsIndex = liveUnindexed > 0;
  const sourceLabel = source === "yt" ? "YouTube" : "X";

  const handleSync = () => {
    void runSyncEmbeddings({
      source,
      onProgress: ({ done, remaining }) => {
        setLiveIndexed(indexed + done);
        setLiveUnindexed(remaining);
      },
    });
  };

  return (
    <div className="rounded-lg bg-surface-container-lowest p-5 shadow-sm border border-outline-variant/30">
      <h2 className="text-base font-semibold">Enrichment &amp; index</h2>
      <p className="mt-0.5 text-[11px] text-on-surface-variant">
        Counts for this tab ({sourceLabel}) only
      </p>

      <div className="mt-5">
        <div className="flex items-baseline justify-between gap-2">
          <p className="text-[11px] font-bold uppercase tracking-wide text-on-surface-variant/70">
            Index health
          </p>
          <p className="text-xs font-medium text-on-surface-variant">
            {indexable > 0 ? `${Math.round(coverage)}% searchable` : "No content yet"}
          </p>
        </div>

        <div className="mt-2 h-2 overflow-hidden rounded-full bg-surface-container-high">
          <div
            className={`h-full rounded-full transition-all ${needsIndex ? "bg-amber-500" : "bg-primary"}`}
            style={{ width: `${coverage}%` }}
          />
        </div>

        <div className="mt-2 flex flex-wrap items-center gap-x-3 gap-y-1 text-sm">
          <span>
            <span className="font-semibold tabular-nums">{fmt(liveIndexed)}</span>{" "}
            <span className="text-on-surface-variant">indexed</span>
          </span>
          <span className="text-on-surface-variant/40">·</span>
          <span className={needsIndex ? "text-amber-900" : undefined}>
            <span className="font-semibold tabular-nums">{fmt(liveUnindexed)}</span>{" "}
            <span className={needsIndex ? "text-amber-800" : "text-on-surface-variant"}>
              missing
            </span>
          </span>
        </div>
      </div>

      {(needsIndex || syncing) && (
        <div className="mt-4 rounded-lg border border-amber-200 bg-amber-50 px-3 py-3">
          <p className="text-sm font-semibold text-amber-950">
            {syncing
              ? `Indexing… ${fmt(liveUnindexed)} remaining`
              : `${fmt(liveUnindexed)} item${liveUnindexed === 1 ? "" : "s"} not searchable`}
          </p>
          <p className="mt-1 text-xs text-amber-900/80 leading-snug">
            {syncing
              ? "Progress matches this tab’s missing queue (summarized items without embeddings)."
              : "Summarized items without embeddings — semantic search will skip them until indexed."}
          </p>
          <button
            type="button"
            onClick={handleSync}
            disabled={syncing || liveUnindexed === 0}
            className="mt-3 rounded-lg bg-amber-800 px-4 py-2 text-xs font-semibold text-white transition hover:bg-amber-900 disabled:opacity-60"
          >
            {syncing ? "Syncing embeddings…" : "Sync embeddings"}
          </button>
          {message && <p className="mt-2 text-xs text-amber-900/90">{message}</p>}
        </div>
      )}

      <div className="mt-5 border-t border-outline-variant/30 pt-4">
        <p className="text-[11px] font-bold uppercase tracking-wide text-on-surface-variant/70">
          Enrichment
        </p>
        <p className="mt-0.5 text-[10px] text-on-surface-variant/70">
          Live library state for this tab (not historical run totals)
        </p>
        <dl className="mt-3 grid grid-cols-2 gap-3 text-sm">
          <div>
            <dt className="text-xs text-on-surface-variant">Summarized</dt>
            <dd className="font-semibold tabular-nums">{fmt(sum)}</dd>
          </div>
          <div>
            <dt className="text-xs text-on-surface-variant">Pending</dt>
            <dd className={`font-semibold tabular-nums ${pend > 0 ? "text-secondary" : ""}`}>
              {fmt(pend)}
            </dd>
          </div>
          <div title="Bookmarks with a current enrichmentError from the last failed attempt">
            <dt className="text-xs text-on-surface-variant">Failed</dt>
            <dd className={`font-semibold tabular-nums ${failed > 0 ? "text-error" : ""}`}>
              {fmt(failed)}
            </dd>
          </div>
          <div title="Still pending after 3+ failures — normal Enrich skips these until reprocess">
            <dt className="text-xs text-on-surface-variant">Blocked</dt>
            <dd className={`font-semibold tabular-nums ${skipped > 0 ? "text-amber-800" : ""}`}>
              {fmt(skipped)}
            </dd>
          </div>
        </dl>
      </div>
    </div>
  );
}
