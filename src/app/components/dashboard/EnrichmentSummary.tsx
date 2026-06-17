export function EnrichmentSummary({ sum, pend, failed, skipped }: any) {
  const cell = (v: number, l: string, c?: string) => (
    <div className={`rounded-md p-3 text-center ${c || "bg-surface-container"}`}>
      <p className="font-headline text-2xl">{v}</p>
      <p className={`text-[10px] font-bold uppercase tracking-tight ${c ? "" : "text-on-surface-variant"}`}>{l}</p>
    </div>
  );
  return (
    <div className="rounded-lg bg-surface-container-lowest p-5">
      <h2 className="text-base font-semibold">Enrichment</h2>
      <div className={`mt-6 grid gap-2 ${skipped > 0 ? "grid-cols-4" : "grid-cols-3"}`}>
        {cell(sum, "Done")}
        {cell(pend, "Wait")}
        {cell(failed, "Err", "bg-red-100 text-error")}
        {skipped > 0 && cell(skipped, "Skip", "bg-slate-100 text-on-surface-variant")}
      </div>
    </div>
  );
}
