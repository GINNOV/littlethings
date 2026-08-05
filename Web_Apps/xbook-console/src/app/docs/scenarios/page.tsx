import Link from "next/link";

type Scenario = {
  id: string;
  badge: string;
  badgeClass: string;
  title: string;
  summary: string;
  steps: string[];
  win: string;
  examplePrompt?: string;
};

const scenarios: Scenario[] = [
  {
    id: "recall",
    badge: "Recall",
    badgeClass: "bg-emerald-500/10 text-emerald-800",
    title: "Find what you saved by idea, not keyword",
    summary:
      "Run Process inbox on your X and YouTube saves, then use semantic search in the Library to surface the right items by meaning.",
    steps: [
      "Bookmark freely on X and YouTube as you discover ideas.",
      "On the Dashboard, click Process inbox (sync + enrich + index in one pass).",
      'In the Library, search by concept—e.g. "housing policy arguments" or "local LLM setup tips."',
    ],
    win: "Your bookmark graveyard becomes a private, searchable second brain—no exact phrase required.",
  },
  {
    id: "create",
    badge: "Create",
    badgeClass: "bg-primary/10 text-primary",
    title: "Turn saves into drafts with a local agent",
    summary:
      "After enrichment, structured summaries and tags are available via the Agent API so local agents can draft notes, outlines, or briefs without re-reading every link.",
    steps: [
      "Run Process inbox regularly so summaries and search indexes stay current.",
      "Point a local agent at /api/agent.",
      "Ask it to gather bookmarks on a topic and draft content in your notes app from those sources.",
    ],
    win: "Capture once while browsing; generate follow-up writing from a private, local knowledge base.",
  },
  {
    id: "hermes-obsidian",
    badge: "Hermes + Obsidian",
    badgeClass: "bg-slate-900 text-white",
    title: "Bookmark a xeet, ask Hermes to write the tutorial in Obsidian",
    summary:
      "A common Xbook loop: save a useful post on X, enrich it, then have Hermes call /api/agent to search that bookmark and expand it into a full tutorial or how-to note in your Obsidian vault.",
    steps: [
      "Bookmark the xeet/tweet (or short thread) while you browse.",
      "In Xbook, run Process inbox so the item is summarized and searchable.",
      "Point Hermes at http://localhost:3000/api/agent (see Settings → Agents for token/status).",
      'Ask Hermes to search bookmarks (resource=bookmarks&q=…), read the match (text, summary, tweet URL), and write a step-by-step tutorial in Obsidian grounded in that post—keeping the original link as the source.',
      "Optional: have Hermes append a short note or tag back via appendBookmarkData so the bookmark records that a tutorial was written.",
    ],
    win: "One bookmarked post becomes a full tutorial in your vault—no copy-paste archaeology.",
    examplePrompt: `Use the Xbook Agent API at http://localhost:3000/api/agent.
Search my bookmarks for the post I saved about [topic / author / phrase].
Read the matching bookmark (text + summary + tweet URL).
Write a practical tutorial in my Obsidian vault based on that xeet—expand steps, add caveats, keep the original link as the source.`,
  },
];

export default function DocsScenariosPage() {
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
            Scenarios
          </h1>
          <p className="max-w-2xl text-lg text-on-surface-variant leading-relaxed">
            Practical ways to leverage Xbook. We highlight a few strong patterns here and will
            expand this catalog as more use cases emerge.
          </p>
        </header>

        <div className="space-y-6">
          {scenarios.map((scenario, index) => (
            <article
              key={scenario.id}
              id={scenario.id}
              className="rounded-2xl bg-white p-8 shadow-sm border border-outline-variant/30 space-y-4"
            >
              <div className="flex flex-wrap items-center gap-3">
                <span
                  className={`inline-flex items-center rounded-full px-3 py-1 text-xs font-bold uppercase tracking-wide ${scenario.badgeClass}`}
                >
                  Scenario {index + 1} · {scenario.badge}
                </span>
              </div>
              <h2 className="text-2xl font-bold text-on-surface">{scenario.title}</h2>
              <p className="text-sm text-on-surface-variant leading-6">{scenario.summary}</p>
              <div className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4 space-y-2">
                <p className="text-xs font-bold uppercase text-on-surface-variant">
                  How to leverage it
                </p>
                <ol className="list-decimal list-inside space-y-1.5 text-sm text-on-surface-variant leading-6">
                  {scenario.steps.map((step) => (
                    <li key={step}>{step}</li>
                  ))}
                </ol>
              </div>
              {scenario.examplePrompt ? (
                <div className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4 space-y-2">
                  <p className="text-xs font-bold uppercase text-on-surface-variant">
                    Example Hermes ask
                  </p>
                  <pre className="overflow-x-auto rounded-lg bg-slate-950 p-3 text-xs leading-5 text-slate-100 whitespace-pre-wrap">
                    {scenario.examplePrompt}
                  </pre>
                </div>
              ) : null}
              <p className="text-sm font-semibold text-primary">Win: {scenario.win}</p>
            </article>
          ))}
        </div>

        <section className="rounded-2xl border border-dashed border-outline-variant/50 bg-white/60 p-8 text-center space-y-3">
          <h2 className="text-xl font-bold text-on-surface">More coming soon</h2>
          <p className="mx-auto max-w-xl text-sm text-on-surface-variant leading-6">
            This page is the home for additional scenarios as we document them—triage workflows,
            research sprints, playlist deep-dives, and more agent automations.
          </p>
        </section>

        <footer className="pt-8 border-t border-outline-ghost flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex flex-wrap items-center gap-4">
            <Link href="/docs" className="text-sm font-semibold text-primary hover:underline">
              ← Back to Docs
            </Link>
            <Link href="/docs/library" className="text-sm font-semibold text-on-surface-variant hover:text-primary">
              Library reference
            </Link>
          </div>
          <Link
            href="/"
            className="rounded-full bg-black px-8 py-3 text-sm font-bold text-white shadow-xl transition hover:scale-105 active:scale-95"
          >
            Back to Dashboard
          </Link>
        </footer>
      </div>
    </main>
  );
}
