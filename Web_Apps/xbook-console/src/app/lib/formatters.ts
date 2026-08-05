export const formatDate = (v: any) => v ? new Date(v).toLocaleString() : "Not finished";
export const formatDateShort = (v: any) => v ? new Date(v).toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: '2-digit' }) : "-";
export const formatTime = (v: any) => v ? new Date(v).toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' }) : "-";

/** Human label for OperationRun.source (x / yt / system / other). */
export function formatRunSource(source?: string | null): string {
  if (source === "x") return "X";
  if (source === "yt") return "YouTube";
  if (source === "system") return "System";
  if (source?.trim()) return source.trim().toUpperCase();
  return "Unknown";
}

const RUN_TYPE_LABELS: Record<string, string> = {
  enrichment_batch: "Enrichment batch",
  enrichment_full: "Enrich all",
  enrichment_full_reprocess: "Force reprocess all",
  folder_enrichment: "Folder enrichment",
  single_reprocess: "Single reprocess",
  embedding_sync: "Embedding sync",
  x_sync: "X sync",
  youtube_sync: "YouTube sync",
};

/** Type label only, e.g. "enrichment_full_reprocess" → "Force reprocess all". */
export function formatRunType(type: string): string {
  const key = type || "operation";
  return (
    RUN_TYPE_LABELS[key] ??
    key.replaceAll("_", " ").replace(/^\w/, (c) => c.toUpperCase())
  );
}

/** e.g. "enrichment_full_reprocess" + "x" → "Force reprocess all · X" */
export function formatRunTitle(type: string, source?: string | null): string {
  const pretty = formatRunType(type);
  const src = formatRunSource(source);
  if (src === "Unknown") return pretty;
  return `${pretty} · ${src}`;
}

export const statusClass = (s: string) => {
  if (s === "completed") return "text-primary";
  if (["failed", "stopped"].includes(s)) return "text-error";
  return "text-secondary";
};

/** Minimal run shape for outcome secondary lines (dashboard + processing list). */
export type RunOutcomeInput = {
  status: string;
  total?: number | null;
  processed?: number | null;
  updated?: number | null;
  failed?: number | null;
  skipped?: number | null;
  notes?: string | null;
};

/**
 * Compact outcome summary from OperationRun counters.
 * Prefers counts over generic notes; falls back to notes / "No details".
 */
export function formatRunOutcome(run: RunOutcomeInput): string {
  const total = Number(run.total ?? 0) || 0;
  const processed = Number(run.processed ?? 0) || 0;
  const updated = Number(run.updated ?? 0) || 0;
  const failed = Number(run.failed ?? 0) || 0;
  const skipped = Number(run.skipped ?? 0) || 0;
  const status = (run.status ?? "").toLowerCase();
  const inFlight = status === "running" || status === "queued";

  const segments: string[] = [];

  if (updated > 0) segments.push(`${updated} updated`);
  if (failed > 0) segments.push(`${failed} failed`);
  if (skipped > 0) segments.push(`${skipped} skipped`);

  const hasResultSegments = segments.length > 0;
  // Progress while queued/running, or when we only have totals and no outcome counts yet.
  const showProgress = total > 0 && (inFlight || !hasResultSegments);

  if (showProgress) {
    segments.unshift(`${processed}/${total} processed`);
  } else if (!hasResultSegments && processed > 0) {
    segments.push(`${processed} processed`);
  }

  if (segments.length > 0) return segments.join(" · ");

  const notes = (run.notes ?? "").trim();
  return notes || "No details";
}
