"use client";

import { useActions } from "../hooks/useActions";

type Props = {
  enrichBatchSize: number; source: "x" | "yt"; pendingCount: number;
  soundOnComplete?: boolean; soundOnError?: boolean;
};

export default function Actions({ enrichBatchSize, source, pendingCount, soundOnComplete, soundOnError }: Props) {
  const { loading, message, toast, runImport, runEnrich } = useActions(source, enrichBatchSize, soundOnComplete, soundOnError);
  const isEnriching = source === "x" ? loading.enrichX : loading.enrichYt;
  const isSyncing = source === "x" ? loading.x : loading.yt;

  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap gap-3">
        <button onClick={runImport} disabled={isSyncing} className={`rounded-full px-5 py-2 text-sm font-semibold text-white transition disabled:opacity-60 ${source === "x" ? "bg-black" : "bg-red-700"}`}>
          {isSyncing ? "Syncing..." : `Sync ${source.toUpperCase()}`}
        </button>
        <button onClick={() => runEnrich(true)} disabled={isEnriching || pendingCount === 0} className={`rounded-full px-5 py-2 text-sm font-semibold text-white transition disabled:opacity-60 ${source === "x" ? "bg-black" : "bg-primary"}`}>
          {isEnriching ? "Enriching..." : `Enrich all ${source.toUpperCase()} (${pendingCount})`}
        </button>
        <button onClick={() => runEnrich(false)} disabled={isEnriching || pendingCount === 0} className="rounded-full border border-black/20 px-5 py-2 text-sm font-semibold text-black transition disabled:opacity-60">
          {`Batch (${source === "yt" ? 200 : enrichBatchSize})`}
        </button>
      </div>
      {message && <p className="text-sm text-slate-700">{message}</p>}
      {toast && <div className="rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-800">{toast}</div>}
    </div>
  );
}
