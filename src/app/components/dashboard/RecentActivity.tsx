import Link from "next/link";
import { OperationRun } from "@prisma/client";
import { formatDateShort, formatTime, statusClass } from "@/app/lib/formatters";

type Props = {
  operationRuns: OperationRun[];
};

export function RecentActivity({ operationRuns }: Props) {
  return (
    <section className="rounded-lg bg-surface-container-lowest p-5 shadow-sm border border-outline-variant/30">
      <h2 className="text-base font-semibold">Recent activity</h2>
      <div className="mt-4 flex flex-col gap-2">
        {operationRuns.map((run) => (
          <Link
            key={run.id}
            href={`/processing?runId=${run.id}`}
            className="grid grid-cols-[1fr_auto_100px] items-center gap-6 rounded-lg bg-surface-container-low px-4 py-3 text-sm hover:bg-surface-container transition-all"
          >
            <div className="min-w-0">
              <span className="block font-semibold capitalize truncate">{run.type.replaceAll("_", " ")}</span>
              <span className="text-[11px] text-on-surface-variant line-clamp-1">{run.notes ?? "No details"}</span>
            </div>
            
            <div className="flex flex-col items-end gap-0.5 whitespace-nowrap">
              <span className="text-xs font-medium text-on-surface">{formatDateShort(run.startedAt)}</span>
              <span className="text-[10px] text-on-surface-variant">{formatTime(run.startedAt)}</span>
            </div>

            <div className="flex justify-end">
              <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider ${statusClass(run.status)} bg-opacity-10 border border-current`}>
                {run.status}
              </span>
            </div>
          </Link>
        ))}
        {operationRuns.length === 0 ? (
          <p className="text-sm text-on-surface-variant py-4 italic">No processing activity yet.</p>
        ) : null}
      </div>
    </section>
  );
}
