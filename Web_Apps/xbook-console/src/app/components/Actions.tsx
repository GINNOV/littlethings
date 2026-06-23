"use client";

import { useState } from "react";
import { useActions } from "../hooks/useActions";

type Props = {
  enrichBatchSize: number; 
  source: "x" | "yt"; 
  pendingCount: number;
  totalCount?: number;
  soundOnComplete?: boolean; 
  soundOnError?: boolean;
};

export default function Actions({ enrichBatchSize, source, pendingCount, totalCount = 0, soundOnComplete, soundOnError }: Props) {
  const [reprocessAll, setReprocessAll] = useState(false);
  const { loading, message, toast, runImport, runEnrich } = useActions(source, enrichBatchSize, soundOnComplete, soundOnError);
  const isEnriching = source === "x" ? loading.enrichX : loading.enrichYt;
  const isSyncing = source === "x" ? loading.x : loading.yt;

  const activeCount = reprocessAll ? totalCount : pendingCount;

  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap gap-3">
        <button onClick={runImport} disabled={isSyncing} className={`rounded-full px-5 py-2 text-sm font-semibold text-white transition disabled:opacity-60 ${source === "x" ? "bg-black" : "bg-red-700"}`}>
          {isSyncing ? "Syncing..." : `Sync ${source.toUpperCase()}`}
        </button>
        <button onClick={() => runEnrich(true, reprocessAll)} disabled={isEnriching || activeCount === 0} className={`rounded-full px-5 py-2 text-sm font-semibold text-white transition disabled:opacity-60 ${source === "x" ? "bg-black" : "bg-primary"}`}>
          {isEnriching ? "Enriching..." : reprocessAll ? `Reprocess all ${source.toUpperCase()} (${totalCount})` : `Enrich all ${source.toUpperCase()} (${pendingCount})`}
        </button>
        <button onClick={() => runEnrich(false, reprocessAll)} disabled={isEnriching || activeCount === 0} className="rounded-full border border-black/20 px-5 py-2 text-sm font-semibold text-black transition disabled:opacity-60">
          {`Batch (${source === "yt" ? 200 : enrichBatchSize})`}
        </button>
      </div>
      
      <div className="flex items-center gap-2 mt-1">
        <input 
          id={`reprocess-all-${source}`}
          type="checkbox"
          checked={reprocessAll}
          onChange={(e) => setReprocessAll(e.target.checked)}
          className="h-4 w-4 rounded border-outline-variant text-primary focus:ring-primary/20 accent-primary"
        />
        <label htmlFor={`reprocess-all-${source}`} className="text-xs font-medium text-slate-600 cursor-pointer select-none">
          Force reprocess already enriched
        </label>
      </div>

      {message && <p className="text-sm text-slate-700">{message}</p>}
      {toast && <div className="rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-800">{toast}</div>}
    </div>
  );
}
