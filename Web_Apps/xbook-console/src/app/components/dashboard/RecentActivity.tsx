import Link from "next/link";
import type { OperationRun } from "@prisma/client";
import { XLogo, YouTubeLogo } from "../Icons";
import {
  formatDateShort,
  formatRunOutcome,
  formatRunSource,
  formatRunType,
  formatTime,
  statusClass,
} from "@/app/lib/formatters";
import {
  formatRunConfig,
  resolveRunConfig,
  runConfigParts,
  type OperationRunConfig,
} from "@/lib/run-config";

type RunRow = OperationRun & {
  llmRequests?: Array<{ model: string | null; baseUrl: string | null }>;
};

type Props = {
  operationRuns: RunRow[];
};

/** Source as a single icon (or compact text for non-brand sources). */
function SourceBadge({ source }: { source?: string | null }) {
  if (source === "yt") {
    return (
      <span
        className="inline-flex shrink-0 items-center justify-center rounded px-1.5 py-0.5 bg-error/10 text-error"
        title="YouTube"
        aria-label="YouTube"
      >
        <YouTubeLogo className="h-2.5 w-3" />
      </span>
    );
  }
  if (source === "x") {
    return (
      <span
        className="inline-flex shrink-0 items-center justify-center rounded px-1.5 py-0.5 bg-on-surface/10 text-on-surface"
        title="X"
        aria-label="X"
      >
        <XLogo className="h-2.5 w-2.5" />
      </span>
    );
  }
  return (
    <span
      className="inline-flex shrink-0 items-center rounded px-1.5 py-0.5 bg-surface-container-high text-on-surface-variant"
      title={formatRunSource(source)}
    >
      <span className="text-[10px] font-bold uppercase tracking-wide">{formatRunSource(source)}</span>
    </span>
  );
}

function resolvedConfig(run: RunRow): OperationRunConfig | null {
  const firstLlm = run.llmRequests?.[0];
  return resolveRunConfig({
    configJson: run.configJson,
    llmModel: firstLlm?.model,
    llmBaseUrl: firstLlm?.baseUrl,
    notes: run.notes,
  });
}

function ConfigChips({ config }: { config: OperationRunConfig | null }) {
  const parts = runConfigParts(config);
  if (parts.length === 0) {
    return <span className="text-[11px] text-on-surface-variant/50">—</span>;
  }
  return (
    <div className="flex min-w-0 flex-wrap items-center gap-1.5" title={formatRunConfig(config) ?? undefined}>
      {parts.map((part) => (
        <span
          key={part.key}
          title={part.title}
          className="inline-flex max-w-full truncate rounded-md bg-surface-container-highest/60 px-1.5 py-0.5 text-[10px] font-medium text-on-surface-variant font-mono tracking-tight"
        >
          {part.label}
        </span>
      ))}
    </div>
  );
}

export function RecentActivity({ operationRuns }: Props) {
  return (
    <section className="rounded-lg bg-surface-container-lowest p-5 shadow-sm border border-outline-variant/30">
      <h2 className="text-base font-semibold">Recent activity</h2>

      <div className="mt-4 hidden grid-cols-[minmax(11rem,1.05fr)_minmax(10rem,0.95fr)_minmax(18rem,1.9fr)_5.5rem_5.5rem] gap-x-4 px-4 text-[10px] font-bold uppercase tracking-wider text-on-surface-variant md:grid">
        <span>Operation</span>
        <span>Progress</span>
        <span>Model · machine · batch · settings</span>
        <span className="text-right">When</span>
        <span className="text-right">Status</span>
      </div>

      <div className="mt-2 flex flex-col gap-2">
        {operationRuns.map((run) => {
          const config = resolvedConfig(run);
          return (
            <Link
              key={run.id}
              href={`/processing?runId=${run.id}`}
              className="grid grid-cols-1 items-center gap-2 rounded-lg bg-surface-container-low px-4 py-3 text-sm hover:bg-surface-container transition-all md:grid-cols-[minmax(11rem,1.05fr)_minmax(10rem,0.95fr)_minmax(18rem,1.9fr)_5.5rem_5.5rem] md:gap-x-4"
            >
              <div className="flex min-w-0 items-center gap-2">
                <span className="font-semibold truncate">{formatRunType(run.type)}</span>
                <SourceBadge source={run.source} />
              </div>

              <span className="min-w-0 text-[11px] text-on-surface-variant truncate">
                {formatRunOutcome(run)}
              </span>

              <ConfigChips config={config} />

              <div className="flex flex-row items-center gap-2 md:flex-col md:items-end md:gap-0.5 whitespace-nowrap">
                <span className="text-xs font-medium text-on-surface">{formatDateShort(run.startedAt)}</span>
                <span className="text-[10px] text-on-surface-variant">{formatTime(run.startedAt)}</span>
              </div>

              <div className="flex md:justify-end">
                <span
                  className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider ${statusClass(run.status)} bg-opacity-10 border border-current`}
                >
                  {run.status}
                </span>
              </div>
            </Link>
          );
        })}
        {operationRuns.length === 0 ? (
          <p className="text-sm text-on-surface-variant py-4 italic">No processing activity yet.</p>
        ) : null}
      </div>
    </section>
  );
}
