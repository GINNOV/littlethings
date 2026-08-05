"use client";

import { useState } from "react";
import { useActions } from "../hooks/useActions";
import { HelpTooltip } from "./settings/SharedFields";

type Props = {
  enrichBatchSize: number;
  source: "x" | "yt";
  pendingCount: number;
  totalCount?: number;
  soundOnComplete?: boolean;
  soundOnError?: boolean;
};

export default function Actions({
  enrichBatchSize,
  source,
  pendingCount,
  totalCount = 0,
  soundOnComplete,
  soundOnError,
}: Props) {
  const [reprocessAll, setReprocessAll] = useState(false);
  const [showAdvanced, setShowAdvanced] = useState(false);
  const {
    loading,
    message,
    toast,
    cancelling,
    runImport,
    runEnrich,
    runProcessInbox,
    cancelOperation,
  } = useActions(source, enrichBatchSize, soundOnComplete, soundOnError);
  const isEnriching = source === "x" ? loading.enrichX : loading.enrichYt;
  const isSyncing = source === "x" ? loading.x : loading.yt;
  const isInbox = source === "x" ? loading.inboxX : loading.inboxYt;
  const busy = isEnriching || isSyncing || isInbox;

  const activeCount = reprocessAll ? totalCount : pendingCount;
  const primaryClass =
    source === "x"
      ? "bg-black text-white hover:bg-black/90"
      : "bg-red-700 text-white hover:bg-red-800";

  const busyLabel = isInbox
    ? "Processing…"
    : isEnriching
      ? "Enriching…"
      : isSyncing
        ? "Syncing…"
        : null;

  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap items-center gap-2">
        <button
          type="button"
          onClick={() => void runProcessInbox()}
          disabled={busy}
          className={`rounded-full px-5 py-2 text-sm font-semibold transition disabled:opacity-60 ${primaryClass}`}
        >
          {isInbox ? "Processing…" : "Process inbox"}
        </button>
        {busy && (
          <button
            type="button"
            onClick={() => void cancelOperation()}
            disabled={cancelling}
            className="rounded-full border border-error px-4 py-2 text-sm font-semibold text-error transition hover:bg-error hover:text-white disabled:opacity-60"
            title="Stop the current operation so you can start another"
          >
            {cancelling ? "Stopping…" : "Stop"}
          </button>
        )}
        <HelpTooltip text="Import new bookmarks, enrich items that still need a summary, then index missing embeddings for search. The day-to-day path. Use Stop if you need to switch to another operation mid-run." />
      </div>
      {busy && busyLabel && (
        <p className="text-xs font-medium text-on-surface-variant">
          {busyLabel} Stop to free the queue and start a different operation.
        </p>
      )}

      <div>
        <button
          type="button"
          onClick={() => setShowAdvanced((v) => !v)}
          aria-expanded={showAdvanced}
          className="flex items-center gap-2 text-xs font-semibold text-on-surface-variant transition hover:text-on-surface"
        >
          <span className="text-[10px] font-bold">{showAdvanced ? "▲" : "▼"}</span>
          Advanced actions
        </button>

        {showAdvanced && (
          <div className="mt-3 flex flex-col gap-3 border-t border-outline-variant/30 pt-3">
            <div className="flex flex-wrap gap-3">
              <button
                type="button"
                onClick={runImport}
                disabled={busy}
                className={`rounded-full px-5 py-2 text-sm font-semibold text-white transition disabled:opacity-60 ${
                  source === "x" ? "bg-black" : "bg-red-700"
                }`}
              >
                {isSyncing ? "Syncing..." : `Sync ${source.toUpperCase()}`}
              </button>
              <button
                type="button"
                onClick={() => runEnrich(true, reprocessAll)}
                disabled={busy || activeCount === 0}
                className={`rounded-full px-5 py-2 text-sm font-semibold text-white transition disabled:opacity-60 ${
                  source === "x" ? "bg-black" : "bg-primary"
                }`}
              >
                {isEnriching
                  ? "Enriching..."
                  : reprocessAll
                    ? `Reprocess all ${source.toUpperCase()} (${totalCount})`
                    : `Enrich all ${source.toUpperCase()} (${pendingCount})`}
              </button>
              <button
                type="button"
                onClick={() => runEnrich(false, reprocessAll)}
                disabled={busy || activeCount === 0}
                className="rounded-full border border-black/20 px-5 py-2 text-sm font-semibold text-black transition disabled:opacity-60"
              >
                {`Batch (${source === "yt" ? 200 : enrichBatchSize})`}
              </button>
            </div>

            <div className="mt-1 flex items-center gap-2">
              <input
                id={`reprocess-all-${source}`}
                type="checkbox"
                checked={reprocessAll}
                onChange={(e) => setReprocessAll(e.target.checked)}
                className="h-4 w-4 rounded border-outline-variant text-primary accent-primary focus:ring-primary/20"
              />
              <label
                htmlFor={`reprocess-all-${source}`}
                className="cursor-pointer select-none text-xs font-medium text-slate-600"
              >
                Force reprocess already enriched
              </label>
            </div>
          </div>
        )}
      </div>

      {message && <p className="text-sm text-slate-700">{message}</p>}
      {toast && (
        <div className="rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-800">
          {toast}
        </div>
      )}
    </div>
  );
}
