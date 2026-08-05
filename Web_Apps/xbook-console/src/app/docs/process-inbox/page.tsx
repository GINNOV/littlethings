import Link from "next/link";
import { DocsPageShell } from "../DocsPageShell";

export default function DocsProcessInboxPage() {
  return (
    <DocsPageShell
      title="Process inbox"
      description="The day-to-day control on the Dashboard: import new items, enrich pending ones, and index embeddings for search."
    >
      <div className="space-y-8">
        <p className="text-on-surface-variant max-w-2xl leading-relaxed">
          On the{" "}
          <Link href="/" className="text-primary hover:underline font-semibold">
            Dashboard
          </Link>
          , each source tab (X or YouTube) has an <strong>Inbox</strong> card. Day-to-day you only need one control.
          Accounts and an LLM should already be configured (
          <Link href="/docs/connections" className="text-primary hover:underline font-semibold">
            connections
          </Link>
          ,{" "}
          <Link href="/docs/llm" className="text-primary hover:underline font-semibold">
            AI
          </Link>
          ).
        </p>

        <div className="rounded-2xl bg-white p-6 shadow-sm border border-outline-variant/30 space-y-4">
          <div className="flex flex-wrap items-center gap-3">
            <span className="rounded-full bg-black px-4 py-1.5 text-sm font-semibold text-white">
              Process inbox
            </span>
            <span className="text-xs font-bold uppercase tracking-wide text-emerald-800">
              Primary · recommended
            </span>
          </div>
          <p className="text-sm text-on-surface-variant leading-6">
            One button that runs the full pipeline for the active tab:
          </p>
          <ol className="list-decimal list-inside space-y-2 text-sm text-on-surface-variant leading-6">
            <li>
              <strong>Sync / import</strong> — pull new bookmarks or saved videos from the platform (no LLM
              required).
            </li>
            <li>
              <strong>Enrich</strong> — send items that still need a summary to your configured LLM for summary,
              category, and tags (needs{" "}
              <Link href="/docs/llm" className="text-primary hover:underline font-semibold">
                LLM setup
              </Link>
              ).
            </li>
            <li>
              <strong>Index embeddings</strong> — generate vectors for semantic search when an embedding model is
              configured.
            </li>
          </ol>
          <p className="text-sm text-on-surface-variant leading-6">
            Progress and errors show under the button and on the{" "}
            <Link href="/processing" className="text-primary hover:underline font-semibold">
              Processing
            </Link>{" "}
            page.
          </p>
        </div>

        <div className="rounded-2xl border border-outline-variant/40 bg-surface-container-lowest p-6 space-y-4">
          <h2 className="text-lg font-bold text-on-surface">Advanced actions</h2>
          <p className="text-sm text-on-surface-variant leading-6">
            Expand <strong>Advanced actions</strong> on the same Inbox card when you need finer control:
          </p>
          <div className="grid gap-3 md:grid-cols-2">
            <div className="rounded-xl border border-outline-variant/40 bg-white p-4 space-y-1">
              <p className="text-sm font-bold text-on-surface">Sync X / Sync YT</p>
              <p className="text-sm text-on-surface-variant leading-6">
                Import only—fetch new items without enriching.
              </p>
            </div>
            <div className="rounded-xl border border-outline-variant/40 bg-white p-4 space-y-1">
              <p className="text-sm font-bold text-on-surface">Enrich all</p>
              <p className="text-sm text-on-surface-variant leading-6">
                Summarize every pending item (or all items if force reprocess is on).
              </p>
            </div>
            <div className="rounded-xl border border-outline-variant/40 bg-white p-4 space-y-1">
              <p className="text-sm font-bold text-on-surface">Batch</p>
              <p className="text-sm text-on-surface-variant leading-6">
                Enrich a limited batch (size from Settings for X; fixed for YouTube).
              </p>
            </div>
            <div className="rounded-xl border border-outline-variant/40 bg-white p-4 space-y-1">
              <p className="text-sm font-bold text-on-surface">Force reprocess</p>
              <p className="text-sm text-on-surface-variant leading-6">
                Checkbox to re-run enrichment on items that already have summaries (e.g. after changing prompts or
                models).
              </p>
            </div>
          </div>
        </div>
      </div>
    </DocsPageShell>
  );
}
