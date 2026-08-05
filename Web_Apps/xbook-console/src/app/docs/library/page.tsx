import Link from "next/link";

type Term = {
  name: string;
  meaning: string;
  use: string;
};

const fields: Term[] = [
  {
    name: "Source",
    meaning: "Where the bookmark came from: X (Twitter) or YouTube.",
    use: "Use the X / YouTube toggle on the filter bar to browse one library at a time. Counts and category lists are scoped to the selected source.",
  },
  {
    name: "Summary",
    meaning:
      "AI-written digest of the post or video (usually 3–6 sentences). For YouTube, the row title often comes from the video title; the summary is still the enrichment body.",
    use: "Primary text for scanning the list, keyword search, and semantic search embeddings. Empty summary = still pending enrichment.",
  },
  {
    name: "Category",
    meaning:
      "A short topical label assigned during enrichment (e.g. AI, Tech, Business). Suggested set is fixed in the default LLM prompt; values are free-form strings in the database.",
    use: "Filter the library by topic. The filter dropdown and category chips show how many items sit in each category for the current source.",
  },
  {
    name: "Tags",
    meaning: "3–5 high-signal keywords (entities, tools, themes) stored as a comma-separated list.",
    use: "Search and agent queries. Edit tags manually if the model missed a key entity.",
  },
  {
    name: "Status",
    meaning:
      "Enrichment state derived from summary only: Pending (no real summary yet) or Summarized (non-empty summary). Category alone does not mark an item done.",
    use: "Filter Pending to find work still needing Process inbox / Enrich. Summarized for ready-to-search items. Failed appears when pending and the last enrich left an error.",
  },
  {
    name: "Folder",
    meaning:
      "X bookmark folder or YouTube playlist association when imported via folder/playlist sync.",
    use: "Filter by folder to process or review one collection. Facet chips show item counts per folder in the current source.",
  },
  {
    name: "Author / Channel",
    meaning: "X handle (@username) or YouTube channel name from the import payload.",
    use: "Scan and keyword search. Helps agents cite the original creator.",
  },
  {
    name: "Posted / Import dates",
    meaning: "Posted = original create time on the platform. Import = when Xbook stored the item.",
    use: "Rough recency cues while browsing; not primary filters today.",
  },
  {
    name: "Read state",
    meaning: "Whether you marked the item as read in Xbook (independent of the platform).",
    use: "Toggle from the row actions to track personal triage. Read items are dimmed in the list.",
  },
  {
    name: "Embedding",
    meaning:
      "Vector representation of the enriched text used for semantic search. Built after a non-empty summary exists.",
    use: "Required for Semantic Search. Missing embeddings show up on the Dashboard as unindexed; run embedding sync or Process inbox.",
  },
];

const filters: Term[] = [
  {
    name: "Text search",
    meaning: "Substring match across text, summary, category, author, and tags.",
    use: "Default mode next to the search box. Quick find by phrase, handle, or tag.",
  },
  {
    name: "Semantic search",
    meaning: "Embedding similarity—matches by idea, not exact wording. Switch on the search row.",
    use: "Pick Semantic in the mode control beside the box, then search. Needs embeddings (Settings → AI).",
  },
  {
    name: "Ask AI",
    meaning:
      "Chat-style find: retrieve relevant bookmarks by meaning, then your configured LLM answers in plain language with citations.",
    use: "Pick Ask AI, type a question (e.g. “what did I save about local LLMs?”), press Ask. Scoped to the current X or YouTube library.",
  },
  {
    name: "Category / status / videos / folder",
    meaning: "Structured filters on the form row (no counts in the dropdown labels).",
    use: "Narrow the list. For counts, open Browse by category & folder—two columns of clickable pills.",
  },
];

const statuses: { label: string; definition: string }[] = [
  {
    label: "Pending",
    definition:
      "summary is null or empty. The item still needs a real AI summary. A stub category (e.g. Other) without a summary remains pending.",
  },
  {
    label: "Summarized",
    definition:
      "summary is a non-empty string. Dashboard totals, library filters, and enrich skip-logic all use this definition.",
  },
  {
    label: "Failed",
    definition:
      "Shown in the Status column when the item is still pending and enrichmentError (or a recent failed processing event) is set. Filter by Pending to surface them, then reprocess or fix the LLM connection.",
  },
  {
    label: "Edited",
    definition:
      "You manually changed summary/category/tags. Replaces the normal status label in the column so hand-curated items stand out.",
  },
];

const categories = [
  "AI",
  "Tech",
  "Business",
  "Design",
  "Science",
  "Finance",
  "Health",
  "Career",
  "Productivity",
  "News",
  "Culture",
  "Politics",
  "Education",
  "Entertainment",
  "Music",
  "Shopping",
  "Other",
];

export default function DocsLibraryPage() {
  return (
    <main className="min-h-screen bg-surface-container-low px-4 py-12 lg:px-8 lg:py-16">
      <div className="mx-auto max-w-4xl space-y-12">
        <header className="space-y-4">
          <Link
            href="/docs"
            className="inline-flex text-sm font-semibold text-primary hover:underline"
          >
            ← Back to Docs
          </Link>
          <h1 className="font-headline text-5xl font-semibold tracking-tight text-primary">
            Library reference
          </h1>
          <p className="max-w-2xl text-lg text-on-surface-variant leading-relaxed">
            What lives in the Library, what each field means, and how to use filters, status, and
            categories day to day. Open the live list anytime at{" "}
            <Link href="/bookmarks" className="font-semibold text-primary hover:underline">
              /bookmarks
            </Link>
            .
          </p>
        </header>

        {/* Overview */}
        <section className="space-y-4 rounded-2xl border border-outline-variant/30 bg-white p-8 shadow-sm">
          <h2 className="text-2xl font-bold text-on-surface">What is the Library?</h2>
          <p className="text-sm leading-7 text-on-surface-variant">
            The Library is your local, searchable collection of imported X bookmarks and YouTube
            saves. Import/sync pulls raw items; enrichment adds summary, category, and tags;
            embeddings unlock semantic search. The page at{" "}
            <Link href="/bookmarks" className="font-semibold text-primary hover:underline">
              Library
            </Link>{" "}
            is the main browser—rows on the left, inspector on the right when you select an item.
          </p>
          <div className="grid gap-4 sm:grid-cols-3">
            {[
              {
                t: "Import",
                d: "Sync or Process inbox copies items into the local SQLite DB.",
              },
              {
                t: "Enrich",
                d: "LLM fills summary, category, tags (and may set enrichment errors on failure).",
              },
              {
                t: "Index",
                d: "Embeddings on summarized items enable semantic (meaning-based) search.",
              },
            ].map((step) => (
              <div
                key={step.t}
                className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4"
              >
                <p className="text-sm font-bold text-primary">{step.t}</p>
                <p className="mt-1 text-sm leading-6 text-on-surface-variant">{step.d}</p>
              </div>
            ))}
          </div>
        </section>

        {/* Facet counts */}
        <section className="space-y-4">
          <h2 className="text-2xl font-bold text-on-surface">Category &amp; folder counts</h2>
          <p className="text-sm leading-7 text-on-surface-variant max-w-2xl">
            Source is chosen from the sidebar (X Library vs YouTube Library)—not duplicated in the
            filter bar. Expand <strong>Browse by category &amp; folder</strong> for a two-column
            accordion of counts. Pills are clickable filters for the current source library.
          </p>
        </section>

        {/* Status */}
        <section className="space-y-4">
          <h2 className="text-2xl font-bold text-on-surface">Status meanings</h2>
          <p className="text-sm leading-7 text-on-surface-variant max-w-2xl">
            Status is defined the same way in the Library filters, Dashboard tiles, and Enrich
            queue: <em>pending means empty summary</em>. That keeps “work remaining” accurate even
            when a stub category was written without a real digest.
          </p>
          <div className="grid gap-4 sm:grid-cols-2">
            {statuses.map((s) => (
              <article
                key={s.label}
                className="rounded-2xl border border-outline-variant/30 bg-white p-6 shadow-sm space-y-2"
              >
                <h3 className="text-lg font-bold text-on-surface">{s.label}</h3>
                <p className="text-sm leading-6 text-on-surface-variant">{s.definition}</p>
              </article>
            ))}
          </div>
        </section>

        {/* Fields */}
        <section className="space-y-6">
          <div className="space-y-2">
            <h2 className="text-2xl font-bold text-on-surface">What&apos;s on each item</h2>
            <p className="text-sm leading-7 text-on-surface-variant max-w-2xl">
              Core fields you see in the grid and inspector—meaning and how to use them.
            </p>
          </div>
          <div className="overflow-hidden rounded-2xl border border-outline-variant/30 bg-white shadow-sm">
            <table className="w-full text-left text-sm">
              <thead className="bg-surface-container text-xs font-semibold uppercase tracking-wide text-on-surface-variant">
                <tr>
                  <th className="px-4 py-3 w-[18%]">Field</th>
                  <th className="px-4 py-3 w-[42%]">Meaning</th>
                  <th className="px-4 py-3">How to use it</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[color-mix(in_srgb,var(--outline-variant)_25%,transparent)]">
                {fields.map((f) => (
                  <tr key={f.name} className="align-top">
                    <td className="px-4 py-3 font-semibold text-on-surface">{f.name}</td>
                    <td className="px-4 py-3 text-on-surface-variant leading-6">{f.meaning}</td>
                    <td className="px-4 py-3 text-on-surface-variant leading-6">{f.use}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>

        {/* Filters */}
        <section className="space-y-6">
          <div className="space-y-2">
            <h2 className="text-2xl font-bold text-on-surface">Filters</h2>
            <p className="text-sm leading-7 text-on-surface-variant max-w-2xl">
              Filters combine with AND. Submit the form (Search) after changing dropdowns; the source
              toggle updates the URL immediately.
            </p>
          </div>
          <div className="grid gap-4">
            {filters.map((f) => (
              <article
                key={f.name}
                className="rounded-2xl border border-outline-variant/30 bg-white p-6 shadow-sm grid gap-2 sm:grid-cols-[160px_1fr]"
              >
                <h3 className="text-base font-bold text-primary">{f.name}</h3>
                <div className="space-y-2 text-sm text-on-surface-variant leading-6">
                  <p>
                    <span className="font-semibold text-on-surface">Meaning: </span>
                    {f.meaning}
                  </p>
                  <p>
                    <span className="font-semibold text-on-surface">Use: </span>
                    {f.use}
                  </p>
                </div>
              </article>
            ))}
          </div>
        </section>

        {/* Categories */}
        <section className="space-y-4">
          <h2 className="text-2xl font-bold text-on-surface">Categories</h2>
          <p className="text-sm leading-7 text-on-surface-variant max-w-2xl">
            The default enrichment prompt asks the model to pick the most specific label from the
            list below. Values are <strong>not</strong> a hard database enum—the model (or you, via
            Edit) can introduce other labels. The Library filter dropdown is{" "}
            <strong>dynamic</strong>: it lists distinct categories already stored for the current
            source, with counts.
          </p>
          <div className="flex flex-wrap gap-2">
            {categories.map((c) => (
              <span
                key={c}
                className="rounded-full bg-surface-container px-3 py-1 text-xs font-semibold text-on-surface"
              >
                {c}
              </span>
            ))}
          </div>
          <div className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4 text-sm text-on-surface-variant leading-6 space-y-2">
            <p>
              <strong className="text-on-surface">Fallback rules:</strong> if the model returns empty
              or &quot;Other&quot;, lightweight keyword heuristics may promote Shopping or Music;
              otherwise Other is kept.
            </p>
            <p>
              <strong className="text-on-surface">Customize:</strong> change the category list in
              Settings → AI (custom system / task prompt). New labels appear in the filter after items
              are enriched with them.
            </p>
          </div>
        </section>

        {/* Row actions */}
        <section className="space-y-4">
          <h2 className="text-2xl font-bold text-on-surface">Row &amp; inspector actions</h2>
          <div className="grid gap-4 sm:grid-cols-2">
            {[
              {
                t: "Open original",
                d: "Jump to the tweet URL or YouTube video in the browser.",
              },
              {
                t: "Mark read / unread",
                d: "Personal triage flag stored only in Xbook.",
              },
              {
                t: "Edit enrichment",
                d: "Manually set summary, category, and tags; marks the item Edited.",
              },
              {
                t: "Reprocess",
                d: "Run enrichment again for one item (useful after LLM or prompt changes).",
              },
              {
                t: "Translate",
                d: "On-demand translation of text/summary via the configured LLM.",
              },
              {
                t: "Inspector",
                d: "Full summary, metadata, and actions without leaving the Library.",
              },
            ].map((a) => (
              <div
                key={a.t}
                className="rounded-xl border border-outline-variant/40 bg-white p-5 shadow-sm space-y-1"
              >
                <p className="font-bold text-on-surface">{a.t}</p>
                <p className="text-sm text-on-surface-variant leading-6">{a.d}</p>
              </div>
            ))}
          </div>
        </section>

        {/* Related */}
        <section className="rounded-2xl border border-outline-variant/30 bg-white p-6 shadow-sm space-y-4">
          <h2 className="text-xl font-bold text-on-surface">Related</h2>
          <ul className="space-y-2 text-sm text-on-surface-variant leading-6">
            <li>
              <Link href="/bookmarks" className="font-semibold text-primary hover:underline">
                Open Library
              </Link>{" "}
              — browse and filter your items.
            </li>
            <li>
              <Link href="/folders" className="font-semibold text-primary hover:underline">
                Folders
              </Link>{" "}
              — sync X folders / YouTube playlists that feed the Library.
            </li>
            <li>
              <Link href="/processing" className="font-semibold text-primary hover:underline">
                Processing
              </Link>{" "}
              — run history when sync or enrich misbehaves.
            </li>
            <li>
              <Link href="/docs/scenarios" className="font-semibold text-primary hover:underline">
                Scenarios
              </Link>{" "}
              — recipes that use the Library (recall, agents, Hermes + Obsidian).
            </li>
            <li>
              <Link href="/docs" className="font-semibold text-primary hover:underline">
                Getting started
              </Link>{" "}
              — connections, LLM setup, and Process inbox.
            </li>
          </ul>
        </section>

        <footer className="flex flex-col items-center justify-between gap-4 border-t border-outline-ghost pt-8 sm:flex-row">
          <Link href="/docs" className="text-sm font-semibold text-primary hover:underline">
            ← Back to Docs
          </Link>
          <Link
            href="/bookmarks"
            className="rounded-full bg-black px-8 py-3 text-sm font-bold text-white shadow-xl transition hover:scale-105 active:scale-95"
          >
            Open Library
          </Link>
        </footer>
      </div>
    </main>
  );
}
