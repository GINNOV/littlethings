import Link from "next/link";

const userGuides = [
  {
    step: "1",
    href: "/docs/settings",
    title: "Settings",
    teaser:
      "Tabs, setup status chips, Save settings, and what each area is for—Connections, AI, Limits, Data, Agents.",
  },
  {
    step: "2",
    href: "/docs/connections",
    title: "Connecting your accounts",
    teaser:
      "Link X and YouTube under Settings → Connections so imports work. OAuth, diagnostics, and troubleshooting.",
  },
  {
    step: "3",
    href: "/docs/llm",
    title: "Configure your AI (LLM)",
    teaser:
      "Enrich and semantic search need a model. LM Studio, Ollama, REMOTE/vLLM, fields that matter, and prompts.",
  },
  {
    step: "4",
    href: "/docs/process-inbox",
    title: "Process inbox",
    teaser:
      "One Dashboard button: sync, enrich pending items, and index embeddings. Advanced Sync / Enrich / Batch too.",
  },
  {
    step: "5",
    href: "/docs/library",
    title: "Library & search",
    teaser:
      "Browse and filter; Text / Semantic / Ask AI on the search row; category & folder counts; field meanings.",
  },
];

const developerGuides = [
  {
    href: "/docs/setup",
    title: "Development setup",
    teaser: "npm install, Prisma migrate, env fallbacks, run / test / e2e / desktop package.",
  },
  {
    href: "/docs/agent-api",
    title: "Agent API",
    teaser: "Local /api/agent for Hermes and scripts—search bookmarks, append notes, auth rules.",
  },
];

export default function DocsPage() {
  return (
    <main className="min-h-screen bg-surface-container-low px-4 py-12 lg:px-8 lg:py-16">
      <div className="mx-auto max-w-4xl space-y-16">
        <header className="space-y-6 text-center">
          <h1 className="font-headline text-6xl font-semibold tracking-tight text-primary">
            Getting Started with Xbook
          </h1>
          <p className="mx-auto max-w-2xl text-xl text-on-surface-variant leading-relaxed italic">
            &quot;Turning your digital pile of links into a searchable personal brain.&quot;
          </p>
        </header>

        <section className="rounded-2xl bg-white p-8 shadow-sm border border-outline-variant/30 space-y-4 text-center">
          <h2 className="text-2xl font-bold text-on-surface">What is XB👀k Console</h2>
          <p className="text-base text-on-surface-variant leading-7 mx-auto max-w-2xl">
            Xbook is a tool that pulls your &quot;bookmarks&quot; from X (Twitter) and your &quot;saved
            videos&quot; from YouTube into one place. It uses an <strong>AI Brain (LLM)</strong> to read them,
            summarize them, and categorize them.
          </p>
        </section>

        {/* Scenarios — full content stays on root */}
        <section className="space-y-8">
          <div className="flex items-center gap-4">
            <span className="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-white font-bold">
              ★
            </span>
            <h2 className="text-3xl font-bold">Scenarios</h2>
          </div>
          <p className="text-on-surface-variant max-w-2xl">
            Two clear wins where Xbook pays for itself—bookmark today, retrieve (or write from) it later without
            digging through platform UIs.
          </p>
          <div className="grid gap-6 md:grid-cols-2">
            <article className="rounded-2xl bg-white p-8 shadow-sm border border-outline-variant/30 space-y-4">
              <div className="inline-flex items-center gap-2 rounded-full bg-emerald-500/10 px-3 py-1 text-xs font-bold uppercase tracking-wide text-emerald-800">
                Scenario 1 · Recall
              </div>
              <h3 className="text-xl font-bold text-on-surface">
                &quot;I know I saved this—find it by idea, not by keyword&quot;
              </h3>
              <p className="text-sm text-on-surface-variant leading-6">
                You bookmark threads and YouTube videos while browsing, then forget the exact titles or authors.
                Process inbox turns that pile into a local library with summaries, tags, and vector embeddings.
              </p>
              <div className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4 space-y-2">
                <p className="text-xs font-bold uppercase text-on-surface-variant">How to leverage it</p>
                <ol className="list-decimal list-inside space-y-1.5 text-sm text-on-surface-variant leading-6">
                  <li>Bookmark freely on X and YouTube as you discover ideas.</li>
                  <li>
                    On the Dashboard, click <strong>Process inbox</strong> (sync + enrich + index in one pass).
                  </li>
                  <li>
                    In the Library, use semantic search—e.g. &quot;housing policy arguments&quot; or &quot;local LLM
                    setup tips&quot;—to surface the right saves by meaning.
                  </li>
                </ol>
              </div>
              <p className="text-sm font-semibold text-primary">
                Win: your bookmark graveyard becomes a private, searchable second brain—no exact phrase required.
              </p>
            </article>

            <article className="rounded-2xl bg-white p-8 shadow-sm border border-outline-variant/30 space-y-4">
              <div className="inline-flex items-center gap-2 rounded-full bg-primary/10 px-3 py-1 text-xs font-bold uppercase tracking-wide text-primary">
                Scenario 2 · Create
              </div>
              <h3 className="text-xl font-bold text-on-surface">
                &quot;Turn what I saved into drafts with a local agent&quot;
              </h3>
              <p className="text-sm text-on-surface-variant leading-6">
                After enrichment, bookmarks are structured (summary, category, tags). Local agents can call the Agent
                API to pull that knowledge into Obsidian notes, blog outlines, or research briefs—without re-reading
                every link.
              </p>
              <div className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4 space-y-2">
                <p className="text-xs font-bold uppercase text-on-surface-variant">How to leverage it</p>
                <ol className="list-decimal list-inside space-y-1.5 text-sm text-on-surface-variant leading-6">
                  <li>
                    Run <strong>Process inbox</strong> regularly so summaries and search indexes stay current.
                  </li>
                  <li>
                    Point a local agent at{" "}
                    <code className="rounded bg-white px-1.5 py-0.5 text-xs">/api/agent</code>.
                  </li>
                  <li>
                    Ask it to gather bookmarks on a topic and draft content in your notes app from those sources.
                  </li>
                </ol>
              </div>
              <p className="text-sm font-semibold text-primary">
                Win: capture once while browsing; generate follow-up writing from a private, local knowledge base.
              </p>
            </article>
          </div>
          <div className="rounded-2xl border border-outline-variant/30 bg-white p-6 shadow-sm flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div className="space-y-1">
              <p className="font-bold text-on-surface">More scenarios</p>
              <p className="text-sm text-on-surface-variant leading-6">
                Explore additional ways people use Xbook—we&apos;ll keep adding recipes as patterns emerge.
              </p>
            </div>
            <Link
              href="/docs/scenarios"
              className="inline-flex shrink-0 items-center justify-center rounded-full bg-primary px-6 py-3 text-sm font-bold text-white shadow-sm transition hover:opacity-90"
            >
              Browse all scenarios →
            </Link>
          </div>
        </section>

        {/* Quick start */}
        <section className="space-y-8">
          <div>
            <h2 className="text-3xl font-bold">Quick start</h2>
            <p className="mt-2 text-on-surface-variant max-w-2xl">
              From a fresh install to searchable bookmarks—do these in order.
            </p>
          </div>
          <ol className="space-y-4">
            {[
              {
                title: "Open Settings and connect a source",
                body: (
                  <>
                    Go to{" "}
                    <Link href="/settings" className="text-primary hover:underline font-semibold">
                      Settings
                    </Link>{" "}
                    → <strong>Connections</strong>. Finish OAuth for X and/or YouTube, then use{" "}
                    <strong>Test connection</strong>.{" "}
                    <Link href="/docs/connections" className="text-primary hover:underline font-semibold">
                      Details
                    </Link>
                  </>
                ),
              },
              {
                title: "Configure the AI (LLM)",
                body: (
                  <>
                    Still in Settings → <strong>AI</strong>: pick a preset (LM Studio, Ollama, …), set the chat
                    model (and an embedding model for semantic search), <strong>Save settings</strong>, then{" "}
                    <strong>Test LLM connection</strong>.{" "}
                    <Link href="/docs/llm" className="text-primary hover:underline font-semibold">
                      Details
                    </Link>
                  </>
                ),
              },
              {
                title: "Process inbox",
                body: (
                  <>
                    On the{" "}
                    <Link href="/" className="text-primary hover:underline font-semibold">
                      Dashboard
                    </Link>
                    , pick the X or YouTube tab and click <strong>Process inbox</strong> (import → enrich → index).{" "}
                    <Link href="/docs/process-inbox" className="text-primary hover:underline font-semibold">
                      Details
                    </Link>
                  </>
                ),
              },
              {
                title: "Search the Library",
                body: (
                  <>
                    Open{" "}
                    <Link href="/bookmarks" className="text-primary hover:underline font-semibold">
                      Library
                    </Link>
                    , filter or search—and check <strong>Semantic Search</strong> when you want idea-based
                    matches.{" "}
                    <Link href="/docs/library" className="text-primary hover:underline font-semibold">
                      Details
                    </Link>
                  </>
                ),
              },
            ].map((step, i) => (
              <li
                key={step.title}
                className="flex gap-4 rounded-2xl border border-outline-variant/30 bg-white p-5 shadow-sm"
              >
                <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-primary text-sm font-bold text-white">
                  {i + 1}
                </span>
                <div className="space-y-1 min-w-0">
                  <p className="font-bold text-on-surface">{step.title}</p>
                  <p className="text-sm text-on-surface-variant leading-6">{step.body}</p>
                </div>
              </li>
            ))}
          </ol>
        </section>

        {/* User guides — teasers */}
        <section className="space-y-8">
          <div>
            <h2 className="text-3xl font-bold">How to use it</h2>
            <p className="mt-2 text-on-surface-variant max-w-2xl">
              Deeper guides for each area. Each card opens a full page.
            </p>
          </div>
          <div className="grid gap-4 md:grid-cols-2">
            {userGuides.map((guide) => (
              <Link
                key={guide.href}
                href={guide.href}
                className="group rounded-2xl bg-white p-6 shadow-sm border border-outline-variant/30 space-y-3 transition hover:border-primary/40 hover:shadow-md"
              >
                <div className="flex items-center gap-3">
                  <span className="flex h-9 w-9 items-center justify-center rounded-full bg-primary text-sm font-bold text-white">
                    {guide.step}
                  </span>
                  <h3 className="text-lg font-bold text-on-surface group-hover:text-primary">{guide.title}</h3>
                </div>
                <p className="text-sm text-on-surface-variant leading-6">{guide.teaser}</p>
                <p className="text-sm font-semibold text-primary">Read more →</p>
              </Link>
            ))}
          </div>
        </section>

        {/* Developer guides — teasers */}
        <section className="space-y-8">
          <div>
            <h2 className="text-3xl font-bold">For developers</h2>
            <p className="mt-2 text-on-surface-variant max-w-2xl">
              Local stack and the Agent API for automation.
            </p>
          </div>
          <div className="grid gap-4 md:grid-cols-2">
            {developerGuides.map((guide) => (
              <Link
                key={guide.href}
                href={guide.href}
                className="group rounded-2xl bg-white p-6 shadow-sm border border-outline-variant/30 space-y-3 transition hover:border-primary/40 hover:shadow-md"
              >
                <h3 className="text-lg font-bold text-on-surface group-hover:text-primary">{guide.title}</h3>
                <p className="text-sm text-on-surface-variant leading-6">{guide.teaser}</p>
                <p className="text-sm font-semibold text-primary">Read more →</p>
              </Link>
            ))}
          </div>
        </section>

        <footer className="pt-16 border-t border-outline-ghost flex flex-col items-center gap-6">
          <div className="text-center space-y-2">
            <p className="font-bold italic">&quot;Never lose a digital insight again.&quot;</p>
          </div>
          <Link
            href="/"
            className="rounded-full bg-black px-10 py-4 text-lg font-bold text-white shadow-xl transition hover:scale-105 active:scale-95"
          >
            Back to Dashboard
          </Link>
        </footer>
      </div>
    </main>
  );
}
