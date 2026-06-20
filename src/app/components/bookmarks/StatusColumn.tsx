type Props = { status: string; edited: boolean; error?: string | null; sim?: number; };

export function StatusColumn({ status, edited, error, sim }: Props) {
  const c = status === "Pending" ? "font-semibold text-secondary" : "font-semibold text-primary";
  return (
    <span className={c}>
      {edited ? "Edited" : status === "Pending" && error ? <span className="text-error" title={error}>Failed</span> : status}
      {sim !== undefined && (
        <span className="ml-2 inline-flex items-center rounded-full bg-primary/10 px-1.5 py-0.5 text-[10px] font-bold text-primary">
          {Math.round(sim * 100)}%
        </span>
      )}
    </span>
  );
}
