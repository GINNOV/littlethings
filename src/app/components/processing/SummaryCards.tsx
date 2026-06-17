type Props = {
  summary: {
    activeOperations: number; totalItems: number; totalEnriched: number;
    pendingEnrichment: number; completedToday: number;
  };
};

export function SummaryCards({ summary }: Props) {
  const stats = [
    ["Active operations", summary.activeOperations],
    ["Total items", summary.totalItems],
    ["Enriched items", summary.totalEnriched],
    ["Pending items", summary.pendingEnrichment],
    ["Items enriched today", summary.completedToday],
  ];

  return (
    <section className="grid gap-3 md:grid-cols-5">
      {stats.map(([label, value]) => (
        <div key={label} className="rounded-lg bg-surface-container-lowest p-4">
          <p className="text-xs font-semibold uppercase text-on-surface-variant">{label}</p>
          <p className="mt-2 font-headline text-3xl">{value}</p>
        </div>
      ))}
    </section>
  );
}
