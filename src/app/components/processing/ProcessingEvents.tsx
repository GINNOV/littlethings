import { useState, useMemo } from "react";
import { useRouter } from "next/navigation";
import { statusClass, formatDate } from "@/app/lib/formatters";
import CopyToClipboard from "../CopyToClipboard";
import { Linkify } from "../Linkify";

type Props = {
  events: any[];
  requests: any[];
  search?: string;
};

export function ProcessingEvents({ events, requests, search = "" }: Props) {
  const [filter, setFilter] = useState<"all" | "failed" | "skipped">("all");
  const router = useRouter();
  const [reprocessingId, setReprocessingId] = useState<string | null>(null);

  const handleReprocess = async (bookmarkId: string) => {
    setReprocessingId(bookmarkId);
    try {
      const res = await fetch(`/api/enrich/one?bookmarkId=${bookmarkId}`, { method: "POST" });
      if (!res.ok) {
        const json = await res.json();
        alert(json.error || "Reprocess failed");
      } else {
        router.refresh();
      }
    } catch (err: any) {
      alert(err.message || "Reprocess failed");
    } finally {
      setReprocessingId(null);
    }
  };

  const grouped = useMemo(() => {
    const matchesSearch = (e: any, rs: any[]) => {
      if (!search) return true;
      const s = search.toLowerCase();
      const eventMatch = (
        (e.message?.toLowerCase().includes(s)) ||
        (e.type?.toLowerCase().includes(s)) ||
        (e.status?.toLowerCase().includes(s)) ||
        (e.bookmark?.text?.toLowerCase().includes(s)) ||
        (e.bookmark?.authorUsername?.toLowerCase().includes(s)) ||
        (e.bookmark?.category?.toLowerCase().includes(s))
      );
      if (eventMatch) return true;

      return rs.some(r => 
        (r.model?.toLowerCase().includes(s)) ||
        (r.prompt?.toLowerCase().includes(s)) ||
        (r.response?.toLowerCase().includes(s)) ||
        (r.error?.toLowerCase().includes(s))
      );
    };

    const groups: { bookmark: any; events: any[]; requests: any[]; id: string }[] = [];
    const bookmarkMap = new Map<string, number>();

    events.forEach((e) => {
      const bid = e.bookmarkId;
      if (!bid) {
        groups.push({ bookmark: null, events: [e], requests: [], id: `sys-${e.id}` });
        return;
      }

      if (!bookmarkMap.has(bid)) {
        bookmarkMap.set(bid, groups.length);
        const matchedRequests = requests.filter(r => r.bookmarkId === bid);
        groups.push({ bookmark: e.bookmark, events: [], requests: matchedRequests, id: bid });
      }
      groups[bookmarkMap.get(bid)!].events.push(e);
    });

    return groups.filter((g) => {
      const matchesFilter = filter === "all" || g.events.some(e => e.status === filter);
      if (!matchesFilter) return false;
      return g.events.some(e => matchesSearch(e, g.requests));
    });
  }, [events, requests, filter, search]);

  const btn = (f: string) =>
    `px-3 py-1 rounded-full text-xs font-bold uppercase tracking-tight transition-all ${
      filter === f
        ? "bg-primary text-white shadow-md shadow-primary/20"
        : "bg-surface-container-high text-on-surface-variant hover:bg-surface-container-highest hover:text-on-surface"
    }`;

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <h3 className="text-lg font-semibold tracking-tight">Processing Timeline</h3>
          <span className="rounded-full bg-surface-container-high px-2 py-0.5 text-[10px] font-bold text-on-surface-variant uppercase tracking-widest">
            {grouped.length} items
          </span>
        </div>
        <div className="flex gap-2">
          <button onClick={() => setFilter("all")} className={btn("all")}>All</button>
          <button onClick={() => setFilter("failed")} className={btn("failed")}>Failed</button>
          <button onClick={() => setFilter("skipped")} className={btn("skipped")}>Skipped</button>
        </div>
      </div>

      <div className="flex flex-col gap-4">
        {grouped.map((group, idx) => {
          const hasFailed = group.events.some(e => e.status === "failed");
          return (
            <div
              key={group.id}
              className={`flex flex-col gap-4 rounded-xl p-5 border transition hover:shadow-md ${
                hasFailed 
                  ? "bg-error/5 border-error/20 hover:border-error/30" 
                  : `border-outline-variant/30 hover:border-primary/20 ${idx % 2 === 0 ? "bg-surface-container-lowest" : "bg-surface-container/30"}`
              }`}
            >
              {group.bookmark ? (
                <>
                  <div className="flex flex-col gap-4 xl:flex-row xl:items-start">
                    <div className="w-full xl:w-[360px] xl:flex-shrink-0 space-y-2 border-b border-outline-variant/20 pb-4 xl:border-b-0 xl:border-r xl:pb-0 xl:pr-6">
                      <div className="flex items-center justify-between gap-4">
                        <div className="flex items-center gap-2">
                          {group.bookmark.authorUsername && (
                            <span className="text-xs font-bold text-on-surface truncate">@{group.bookmark.authorUsername}</span>
                          )}
                          <span className="rounded bg-surface-container px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-tight text-on-surface-variant/80">
                            {group.bookmark.source.toUpperCase()} · {group.bookmark.category ?? "UNCATEGORIZED"}
                          </span>
                        </div>
                        <div className="flex items-center gap-3">
                          <button
                            onClick={() => handleReprocess(group.bookmark.id)}
                            disabled={reprocessingId === group.bookmark.id}
                            className="text-[10px] font-bold text-primary hover:underline uppercase tracking-widest whitespace-nowrap disabled:opacity-50 cursor-pointer"
                          >
                            {reprocessingId === group.bookmark.id ? "Reprocessing..." : "Reprocess ↻"}
                          </button>
                          <span className="text-[10px] text-outline-variant/30">•</span>
                          <a
                            href={group.bookmark.tweetUrl}
                            target="_blank"
                            rel="noreferrer"
                            className="text-[10px] font-bold text-primary hover:underline uppercase tracking-widest whitespace-nowrap"
                          >
                            Source ↗
                          </a>
                        </div>
                      </div>
                      {group.bookmark.text && (
                        <p className="text-sm text-on-surface-variant leading-relaxed italic">
                          <Linkify text={group.bookmark.text} />
                        </p>
                      )}
                    </div>

                    <div className="flex-grow min-w-0">
                      <div className="flex flex-wrap gap-2 overflow-x-auto pb-1">
                        {group.events.map((e) => (
                          <div
                            key={e.id}
                            className={`flex min-w-[160px] flex-col gap-1.5 rounded-lg p-3 border ${
                              e.status === "failed" ? "border-error/20 bg-error/5" : "border-outline-variant/20 bg-surface-container/30"
                            }`}
                          >
                            <div className="flex items-center justify-between gap-2">
                              <span
                                className={`rounded px-1.5 py-0.5 text-[9px] font-bold uppercase tracking-wider ${statusClass(
                                  e.status
                                )} bg-opacity-10 border border-current`}
                              >
                                {e.status}
                              </span>
                              <span className="text-[9px] font-medium text-on-surface-variant opacity-60">
                                {e.createdAt ? new Date(e.createdAt).toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit", second: "2-digit" }) : "-"}
                              </span>
                            </div>
                            <p className="text-[11px] font-medium leading-tight text-on-surface">
                              {e.message ?? e.type}
                            </p>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>

                  {group.requests.length > 0 && (
                    <div className="mt-2 border-t border-outline-variant/20 pt-4">
                      <details className="group">
                        <summary className="cursor-pointer text-[10px] font-bold uppercase tracking-widest text-on-surface-variant/60 hover:text-primary transition-colors list-none flex items-center gap-2">
                          <span className="group-open:rotate-90 transition-transform">▶</span>
                          View Technical LLM Payloads ({group.requests.length})
                        </summary>
                        <div className="mt-4 flex flex-col gap-4">
                          {group.requests.map((r: any) => (
                            <div key={r.id} className="space-y-4 rounded-lg bg-surface-container/20 p-4 border border-outline-variant/10">
                              <div className="flex items-center justify-between gap-4 border-b border-outline-variant/10 pb-2">
                                <span className="text-[10px] font-bold text-on-surface-variant uppercase tracking-tight">
                                  {r.model} · {r.durationMs}ms
                                </span>
                                {r.error && (
                                  <span className="text-[10px] font-bold text-error uppercase">{r.error}</span>
                                )}
                              </div>
                              <div className="grid gap-4 md:grid-cols-2">
                                <PayloadView label="Prompt" text={r.prompt ?? r.promptPreview ?? "Disabled."} />
                                <PayloadView label="Response" text={r.response ?? r.responsePreview ?? "No response."} color="text-primary" />
                              </div>
                            </div>
                          ))}
                        </div>
                      </details>
                    </div>
                  )}
                </>
              ) : (
                <div className="flex items-center justify-between gap-4">
                  <div className="flex items-center gap-3">
                    <span className="rounded px-1.5 py-0.5 text-[10px] font-bold uppercase tracking-wider text-primary bg-primary/10 border border-primary/20">
                      SYSTEM
                    </span>
                    <p className="text-sm font-medium text-on-surface">{group.events[0].message ?? group.events[0].type}</p>
                  </div>
                  <span className="text-[10px] text-on-surface-variant">{formatDate(group.events[0].createdAt)}</span>
                </div>
              )}
            </div>
          );
        })}
        {grouped.length === 0 && (
          <div className="flex flex-col items-center justify-center py-16 text-on-surface-variant opacity-60 border-2 border-dashed border-outline-variant/20 rounded-2xl">
            <p className="text-sm italic">No processing items found matching your criteria.</p>
          </div>
        )}
      </div>
    </div>
  );
}

function PayloadView({ label, text, color }: { label: string; text: string; color?: string }) {
  let formattedText = text;
  if (text) {
    let cleanText = text.trim();
    if (cleanText.startsWith("```")) {
      cleanText = cleanText.replace(/^```[a-zA-Z]*\n?/, "").replace(/\n?```$/, "").trim();
    }
    if (cleanText.startsWith("{") || cleanText.startsWith("[")) {
      try {
        formattedText = JSON.stringify(JSON.parse(cleanText), null, 2);
      } catch {
        // keep as is
      }
    }
  }

  return (
    <div className="flex flex-col gap-1.5">
      <div className="flex items-center justify-between">
        <p className="text-[9px] font-bold uppercase tracking-widest text-on-surface-variant/70">{label}</p>
        <CopyToClipboard text={formattedText} />
      </div>
      <pre className={`max-h-48 overflow-auto whitespace-pre-wrap rounded-lg bg-surface-container-low p-3 text-[10px] font-mono leading-relaxed border border-outline-variant/10 ${color ?? "text-on-surface-variant"}`}>
        {formattedText}
      </pre>
    </div>
  );
}
