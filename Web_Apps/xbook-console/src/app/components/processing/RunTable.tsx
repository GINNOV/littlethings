"use client";

import { XLogo, YouTubeLogo } from "../Icons";
import Link from "next/link";
import { statusClass, formatDate, formatRunOutcome, formatRunTitle } from "@/app/lib/formatters";
import { getFilterUrl } from "@/app/lib/processing-utils";

type Props = {
  runs: any[];
  selectedId: string | null;
  currentParams: any;
};

export function RunTable({ runs, selectedId, currentParams }: Props) {
  return (
    <section className="overflow-hidden rounded-lg bg-surface-container-lowest shadow-sm">
      <div className="grid grid-cols-[1fr_0.4fr_0.6fr_0.6fr] bg-surface-container px-4 py-2 text-[10px] font-bold uppercase tracking-wider text-on-surface-variant">
        <span>Operation</span><span>Source</span><span>Status</span><span>Started</span>
      </div>
      <div className="divide-y divide-outline-variant">
        {runs.map((run) => (
          <Link key={run.id} href={getFilterUrl(currentParams, { runId: run.id })} className={`grid grid-cols-[1fr_0.4fr_0.6fr_0.6fr] px-4 py-3 text-sm transition hover:bg-surface-container-low ${selectedId === run.id ? "bg-surface-container-low shadow-[inset_4px_0_0_var(--primary)]" : ""}`}>
            <div className="flex flex-col">
              <span className="font-semibold">{formatRunTitle(run.type, run.source)}</span>
              <span className="text-[10px] text-on-surface-variant truncate">{formatRunOutcome(run)}</span>
            </div>
            <span className="flex items-center">
              <span className={`flex items-center justify-center rounded px-2 py-0.5 ${run.source === "yt" ? "bg-error/10 text-error" : run.source === "x" ? "bg-on-surface/10 text-on-surface" : "bg-surface-container-high text-on-surface-variant"}`} title={run.source === "yt" ? "YouTube" : run.source === "x" ? "X" : "Mixed"}>
                {run.source === "yt" ? <YouTubeLogo className="h-2.5 w-3" /> : run.source === "x" ? <XLogo className="h-2.5 w-2.5" /> : <span className="text-[10px] font-bold uppercase">mixed</span>}
              </span>
            </span>
            <span className={`font-bold uppercase text-[10px] ${statusClass(run.status)}`}>{run.status}</span>
            <span className="text-xs text-on-surface-variant">{formatDate(run.startedAt)}</span>
          </Link>
        ))}
        {runs.length === 0 && <p className="px-4 py-8 text-sm text-on-surface-variant">No runs match filters.</p>}
      </div>
    </section>
  );
}
