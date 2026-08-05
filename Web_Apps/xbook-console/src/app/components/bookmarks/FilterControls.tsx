"use client";

import Link from "next/link";
import { FormEvent, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import type { FilterCategory, FilterCounts, FilterFolder } from "@/lib/bookmarks";

type SearchMode = "keyword" | "semantic" | "ask";

type Props = {
  categories: FilterCategory[];
  folders: FilterFolder[];
  counts: FilterCounts;
  q: string;
  source: string;
  category: string;
  status: string;
  video: boolean;
  semantic: boolean;
  folderId: string;
};

type AskCitation = {
  id: string;
  reason: string;
  tweetUrl: string;
  summary: string | null;
  text: string | null;
  category: string | null;
  authorUsername: string | null;
  source: string;
};

function Chevron({ open }: { open: boolean }) {
  return (
    <svg
      viewBox="0 0 20 20"
      fill="currentColor"
      className={`h-4 w-4 shrink-0 text-on-surface-variant transition-transform ${open ? "rotate-180" : ""}`}
      aria-hidden
    >
      <path
        fillRule="evenodd"
        d="M5.23 7.21a.75.75 0 011.06.02L10 11.17l3.71-3.94a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z"
        clipRule="evenodd"
      />
    </svg>
  );
}

function FacetPill({
  href,
  label,
  count,
  active,
}: {
  href: string;
  label: string;
  count: number;
  active?: boolean;
}) {
  return (
    <Link
      href={href}
      className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium transition ${
        active
          ? "bg-primary/15 text-primary ring-1 ring-primary/30"
          : "bg-surface-container text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface"
      }`}
    >
      <span className="max-w-[12rem] truncate">{label}</span>
      <span className="tabular-nums font-semibold text-on-surface">{count.toLocaleString()}</span>
    </Link>
  );
}

function buildFilterHref(
  base: { source: string; q: string; status: string; video: boolean; semantic: boolean },
  patch: Record<string, string | null>
) {
  const params = new URLSearchParams();
  if (base.source) params.set("source", base.source);
  if (base.q) params.set("q", base.q);
  if (base.status) params.set("status", base.status);
  if (base.video) params.set("video", "true");
  if (base.semantic) params.set("semantic", "true");

  for (const [key, value] of Object.entries(patch)) {
    if (value === null || value === "") params.delete(key);
    else params.set(key, value);
  }

  const qs = params.toString();
  return qs ? `/bookmarks?${qs}` : "/bookmarks";
}

export function FilterControls({
  categories,
  folders,
  counts,
  q,
  source,
  category,
  status,
  video,
  semantic,
  folderId,
}: Props) {
  const router = useRouter();
  const [mode, setMode] = useState<SearchMode>(semantic ? "semantic" : "keyword");
  const [query, setQuery] = useState(q);
  const [facetsOpen, setFacetsOpen] = useState(false);
  const [askBusy, setAskBusy] = useState(false);
  const [askError, setAskError] = useState<string | null>(null);
  const [askAnswer, setAskAnswer] = useState<string | null>(null);
  const [askCitations, setAskCitations] = useState<AskCitation[]>([]);

  const clearHref = source ? `/bookmarks?source=${encodeURIComponent(source)}` : "/bookmarks";
  const hasFilter = q || category || folderId || status || video || semantic;
  const base = useMemo(
    () => ({ source, q, status, video, semantic: mode === "semantic" }),
    [source, q, status, video, mode]
  );

  const sel =
    "rounded-md border-0 bg-surface-variant px-3 py-2 text-sm focus:ring-1 focus:ring-primary";

  const modeBtn = (m: SearchMode, label: string) => (
    <button
      key={m}
      type="button"
      onClick={() => {
        setMode(m);
        if (m !== "ask") {
          setAskAnswer(null);
          setAskError(null);
          setAskCitations([]);
        }
      }}
      className={`rounded-md px-2.5 py-1.5 text-xs font-semibold transition ${
        mode === m
          ? "bg-surface-container-lowest text-on-surface shadow-sm"
          : "text-on-surface-variant hover:text-on-surface"
      }`}
      aria-pressed={mode === m}
    >
      {label}
    </button>
  );

  const runAsk = async () => {
    const question = query.trim();
    if (!question) {
      setAskError("Type a question first.");
      return;
    }
    setAskBusy(true);
    setAskError(null);
    setAskAnswer(null);
    setAskCitations([]);
    try {
      const res = await fetch("/api/bookmarks/ask", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ question, source: source || null }),
      });
      const json = await res.json();
      if (!res.ok || !json.ok) {
        throw new Error(json.error || `Ask failed (${res.status})`);
      }
      setAskAnswer(json.answer as string);
      setAskCitations((json.citations as AskCitation[]) || []);
    } catch (e) {
      setAskError(e instanceof Error ? e.message : "Ask failed");
    } finally {
      setAskBusy(false);
    }
  };

  const onSubmit = (e: FormEvent<HTMLFormElement>) => {
    if (mode === "ask") {
      e.preventDefault();
      void runAsk();
      return;
    }
    // keyword / semantic: native GET submit
  };

  return (
    <section className="rounded-lg border border-outline-variant/30 bg-surface-container-lowest p-5 shadow-sm">
      <form method="GET" action="/bookmarks" onSubmit={onSubmit} className="space-y-3">
        {source ? <input type="hidden" name="source" value={source} /> : null}
        {mode === "semantic" ? <input type="hidden" name="semantic" value="true" /> : null}

        {/* Search row: box + mode switch */}
        <div className="flex flex-wrap items-stretch gap-2">
          <div className="flex min-w-[min(100%,28rem)] flex-1 items-center gap-0 overflow-hidden rounded-md bg-surface-variant ring-0 focus-within:ring-1 focus-within:ring-primary">
            <input
              type="text"
              name="q"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder={
                mode === "ask"
                  ? "Ask your library… e.g. what did I save about local LLMs?"
                  : mode === "semantic"
                    ? "Search by meaning…"
                    : "Search bookmarks…"
              }
              className="min-w-0 flex-1 border-0 bg-transparent px-4 py-2.5 text-sm focus:outline-none focus:ring-0"
              autoComplete="off"
            />
            <div
              className="mr-1.5 flex shrink-0 items-center gap-0.5 rounded-md bg-surface-container-high/80 p-0.5"
              role="group"
              aria-label="Search mode"
            >
              {modeBtn("keyword", "Text")}
              {modeBtn("semantic", "Semantic")}
              {modeBtn("ask", "Ask AI")}
            </div>
          </div>

          <select name="category" defaultValue={category} className={sel}>
            <option value="">All categories</option>
            {categories.map((c) => (
              <option key={c.name} value={c.name}>
                {c.name}
              </option>
            ))}
          </select>

          <select name="status" defaultValue={status} className={sel}>
            <option value="">All status</option>
            <option value="pending">Pending</option>
            <option value="summarized">Summarized</option>
          </select>

          <select name="video" defaultValue={video ? "true" : ""} className={sel}>
            <option value="">All content</option>
            <option value="true">Videos only</option>
          </select>

          <select name="folderId" defaultValue={folderId} className={sel}>
            <option value="">All folders</option>
            {folders.map((f) => (
              <option key={f.id} value={f.id}>
                {f.name || f.id}
              </option>
            ))}
          </select>

          <button
            type="submit"
            disabled={askBusy}
            className="rounded-md bg-black px-5 py-2 text-sm font-semibold text-white transition hover:bg-black/80 disabled:opacity-60"
          >
            {mode === "ask" ? (askBusy ? "Asking…" : "Ask") : "Search"}
          </button>

          {hasFilter || askAnswer ? (
            <button
              type="button"
              onClick={() => {
                setQuery("");
                setAskAnswer(null);
                setAskError(null);
                setAskCitations([]);
                setMode("keyword");
                router.push(clearHref);
              }}
              className="text-sm font-semibold text-on-surface-variant hover:text-on-surface"
            >
              Clear
            </button>
          ) : null}
        </div>
      </form>

      {/* Ask AI conversation panel */}
      {mode === "ask" ? (
        <div className="mt-4 space-y-3 rounded-xl border border-primary/20 bg-primary/5 p-4">
          <p className="text-xs font-semibold uppercase tracking-wide text-primary">
            Chat find · uses your configured LLM + embeddings
          </p>
          {askError ? <p className="text-sm text-error">{askError}</p> : null}
          {askAnswer ? (
            <div className="space-y-3">
              <div className="rounded-lg bg-surface-container-lowest px-4 py-3 text-sm leading-6 text-on-surface whitespace-pre-wrap">
                {askAnswer}
              </div>
              {askCitations.length > 0 ? (
                <ul className="space-y-2">
                  {askCitations.map((c) => (
                    <li
                      key={c.id}
                      className="rounded-lg border border-outline-variant/30 bg-surface-container-lowest px-3 py-2 text-sm"
                    >
                      <div className="flex flex-wrap items-baseline justify-between gap-2">
                        <span className="font-semibold text-on-surface">
                          {c.category || "Uncategorized"}
                          {c.authorUsername ? (
                            <span className="font-normal text-on-surface-variant">
                              {" "}
                              · @{c.authorUsername.replace(/^@/, "")}
                            </span>
                          ) : null}
                        </span>
                        <a
                          href={c.tweetUrl}
                          target="_blank"
                          rel="noreferrer"
                          className="text-xs font-semibold text-primary hover:underline"
                        >
                          Open →
                        </a>
                      </div>
                      <p className="mt-1 text-xs text-on-surface-variant">{c.reason}</p>
                      <p className="mt-1 line-clamp-2 text-xs text-on-surface-variant">
                        {c.summary || c.text || "No preview"}
                      </p>
                    </li>
                  ))}
                </ul>
              ) : null}
            </div>
          ) : (
            <p className="text-sm text-on-surface-variant leading-6">
              Ask in plain language. Retrieval ranks bookmarks by meaning, then your AI answers with
              citations from this library
              {source === "x" ? " (X only)" : source === "yt" ? " (YouTube only)" : ""}.
            </p>
          )}
        </div>
      ) : null}

      {/* Categories | Folders accordion */}
      <div className="mt-4 border-t border-outline-variant/20 pt-3">
        <button
          type="button"
          onClick={() => setFacetsOpen((o) => !o)}
          className="flex w-full items-center justify-between gap-3 rounded-md py-1 text-left text-sm font-semibold text-on-surface hover:text-primary"
          aria-expanded={facetsOpen}
        >
          <span className="flex flex-wrap items-center gap-x-3 gap-y-1">
            <span>Browse by category &amp; folder</span>
            <span className="text-xs font-medium text-on-surface-variant">
              {categories.length} categories · {folders.length} folders
              {counts.pending > 0 ? ` · ${counts.pending.toLocaleString()} pending` : ""}
            </span>
          </span>
          <Chevron open={facetsOpen} />
        </button>

        {facetsOpen ? (
          <div className="mt-3 grid gap-6 md:grid-cols-2">
            <div className="min-w-0 space-y-2">
              <p className="text-xs font-semibold uppercase tracking-wide text-on-surface-variant">
                Categories
              </p>
              <div className="flex flex-wrap gap-1.5">
                {categories.length === 0 ? (
                  <span className="text-xs text-on-surface-variant">No categories yet</span>
                ) : (
                  categories.map((c) => (
                    <FacetPill
                      key={c.name}
                      href={buildFilterHref(base, {
                        category: category === c.name ? null : c.name,
                        folderId: folderId || null,
                      })}
                      label={c.name}
                      count={c.count}
                      active={category === c.name}
                    />
                  ))
                )}
              </div>
            </div>
            <div className="min-w-0 space-y-2">
              <p className="text-xs font-semibold uppercase tracking-wide text-on-surface-variant">
                Folders
              </p>
              <div className="flex flex-wrap gap-1.5">
                {folders.length === 0 ? (
                  <span className="text-xs text-on-surface-variant">No folders yet</span>
                ) : (
                  folders.map((f) => (
                    <FacetPill
                      key={f.id}
                      href={buildFilterHref(base, {
                        folderId: folderId === f.id ? null : f.id,
                        category: category || null,
                      })}
                      label={f.name || f.id}
                      count={f.count}
                      active={folderId === f.id}
                    />
                  ))
                )}
              </div>
            </div>
          </div>
        ) : null}
      </div>
    </section>
  );
}
