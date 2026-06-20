import Link from "next/link";
import { getProcessingSummary } from "@/lib/processing";
import ProcessingAutoRefresh from "@/app/components/ProcessingAutoRefresh";
import ClearLogsButton from "@/app/components/ClearLogsButton";
import StopAllRunsButton from "@/app/components/StopAllRunsButton";
import { SummaryCards } from "@/app/components/processing/SummaryCards";
import { FilterBar } from "@/app/components/processing/FilterBar";
import { RunTable } from "@/app/components/processing/RunTable";
import { RunDetails } from "@/app/components/processing/RunDetails";
import { getProcessingData } from "@/app/lib/processing-fetcher";

export const dynamic = "force-dynamic";

export default async function ProcessingPage({ searchParams }: { searchParams?: Promise<any> }) {
  const p = await searchParams;
  const { runs, selectedRun, status, source, errorsOnly } = await getProcessingData(p);
  const summary = await getProcessingSummary(source || null);

  const getFilterUrl = (next: any) => {
    const params = new URLSearchParams({ ...p, ...next });
    Object.keys(next).forEach(k => { if (next[k] === null || next[k] === false) params.delete(k); });
    return `/processing?${params.toString()}`;
  };

  return (
    <main className="min-h-screen bg-surface-container-low px-4 py-6 lg:px-8 lg:py-8">
      <ProcessingAutoRefresh enabled={summary.activeOperations > 0 || ["queued", "running"].includes(selectedRun?.status || "")} />
      <div className="mx-auto flex max-w-[1680px] flex-col gap-6">
        <header className="flex flex-col gap-3 md:flex-row md:items-end md:justify-between">
          <h1 className="font-headline text-4xl font-semibold tracking-tight">{source.toUpperCase() || "Library"} Processing</h1>
          <div className="flex items-center gap-3">{summary.activeOperations > 0 && <StopAllRunsButton />}<ClearLogsButton /><Link href={getFilterUrl({})} className="rounded-md bg-primary px-4 py-2 text-sm font-semibold text-white">Refresh</Link></div>
        </header>
        <SummaryCards summary={summary} />
        <FilterBar 
          status={status} 
          source={source} 
          errorsOnly={errorsOnly} 
          currentParams={p} 
        />
        <div className="flex flex-col gap-6">
          <RunTable 
            runs={runs} 
            selectedId={p?.runId || null} 
            currentParams={p} 
          />
          {selectedRun && (
            <section className="rounded-lg bg-surface-container p-6 shadow-sm border border-outline-variant/50">
              <RunDetails 
                selectedRun={selectedRun} 
                currentParams={p} 
              />
            </section>
          )}
        </div>
      </div>
    </main>
  );
}
