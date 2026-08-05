"use client";

import { useState } from "react";
import Link from "next/link";

export default function DocsPage() {
  const [activeTab, setActiveTab] = useState<"user" | "developer">("user");

  return (
    <main className="min-h-screen bg-surface-container-low px-4 py-12 lg:px-8 lg:py-16">
      <div className="mx-auto max-w-4xl space-y-16">
        {/* Welcome Section */}
        <header className="space-y-6 text-center">
          <h1 className="font-headline text-6xl font-semibold tracking-tight text-primary">
            Getting Started with Xbook
          </h1>
          <p className="mx-auto max-w-2xl text-xl text-on-surface-variant leading-relaxed italic">
            &quot;Turning your digital pile of links into a searchable personal brain.&quot;
          </p>
        </header>

        {/* Experience Selector */}
        <div className="flex justify-center">
          <div className="inline-flex rounded-xl bg-surface-container-high p-1 border border-outline-variant/30">
            <button
              onClick={() => setActiveTab("user")}
              className={`rounded-lg px-6 py-2.5 text-sm font-semibold transition-all cursor-pointer ${
                activeTab === "user"
                  ? "bg-white text-primary shadow-sm"
                  : "text-on-surface-variant hover:text-on-surface"
              }`}
            >
              User guide
            </button>
            <button
              onClick={() => setActiveTab("developer")}
              className={`rounded-lg px-6 py-2.5 text-sm font-semibold transition-all cursor-pointer ${
                activeTab === "developer"
                  ? "bg-white text-primary shadow-sm"
                  : "text-on-surface-variant hover:text-on-surface"
              }`}
            >
              Developer
            </button>
          </div>
        </div>

        {activeTab === "user" ? (
          <div className="space-y-16 animate-fadeIn">
            {/* Intro */}
            <section className="rounded-2xl bg-white p-8 shadow-sm border border-outline-variant/30 space-y-4 text-center">
              <h2 className="text-2xl font-bold text-on-surface">What is Xbook?</h2>
              <p className="text-base text-on-surface-variant leading-7 mx-auto max-w-2xl">
                Xbook is a tool that pulls your &quot;bookmarks&quot; from X (Twitter) and your &quot;saved videos&quot; from YouTube into one place. 
                It uses an <strong>AI Brain (LLM)</strong> to read them, summarize them, and categorize them.
              </p>
            </section>

            {/* Scenarios */}
            <section className="space-y-8">
              <div className="flex items-center gap-4">
                <span className="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-white font-bold">★</span>
                <h2 className="text-3xl font-bold">Scenarios</h2>
              </div>
              <p className="text-on-surface-variant max-w-2xl">
                Clear wins where Xbook pays for itself—bookmark today, retrieve later, or hand a saved xeet to Hermes and get a draft in Obsidian.
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
                      <li>On the Dashboard, click <strong>Process inbox</strong> (sync + enrich + index in one pass).</li>
                      <li>In the Library, use semantic search—e.g. &quot;housing policy arguments&quot; or &quot;local LLM setup tips&quot;—to surface the right saves by meaning.</li>
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
                    After enrichment, bookmarks are structured (summary, category, tags). Local agents can call the Agent API
                    to pull that knowledge into Obsidian notes, blog outlines, or research briefs—without re-reading every link.
                  </p>
                  <div className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4 space-y-2">
                    <p className="text-xs font-bold uppercase text-on-surface-variant">How to leverage it</p>
                    <ol className="list-decimal list-inside space-y-1.5 text-sm text-on-surface-variant leading-6">
                      <li>Run <strong>Process inbox</strong> regularly so summaries and search indexes stay current.</li>
                      <li>Point a local agent at <code className="rounded bg-white px-1.5 py-0.5 text-xs">/api/agent</code>.</li>
                      <li>Ask it to gather bookmarks on a topic and draft content in your notes app from those sources.</li>
                    </ol>
                  </div>
                  <p className="text-sm font-semibold text-primary">
                    Win: capture once while browsing; generate follow-up writing from a private, local knowledge base.
                  </p>
                </article>

                <article className="rounded-2xl bg-white p-8 shadow-sm border border-primary/25 md:col-span-2 space-y-4">
                  <div className="inline-flex items-center gap-2 rounded-full bg-slate-900/90 px-3 py-1 text-xs font-bold uppercase tracking-wide text-white">
                    Scenario 3 · Hermes + Obsidian
                  </div>
                  <h3 className="text-xl font-bold text-on-surface">
                    &quot;Bookmark a xeet, ask Hermes to write the tutorial in Obsidian&quot;
                  </h3>
                  <p className="text-sm text-on-surface-variant leading-6 max-w-3xl">
                    A very common loop: you bookmark a useful post (or short thread) on X, enrich it in Xbook, then ask{" "}
                    <strong>Hermes</strong> to call the local Agent API—search for that save, read the summary/text, and draft a
                    longer tutorial or how-to note into your Obsidian vault. Xbook stays the private source of truth; Hermes does the writing.
                  </p>
                  <div className="grid gap-4 md:grid-cols-2">
                    <div className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4 space-y-2">
                      <p className="text-xs font-bold uppercase text-on-surface-variant">How to leverage it</p>
                      <ol className="list-decimal list-inside space-y-1.5 text-sm text-on-surface-variant leading-6">
                        <li>Bookmark the xeet/tweet (or related posts) while you browse.</li>
                        <li>In Xbook: configure the LLM if needed, then <strong>Process inbox</strong> so the item has a summary and is searchable.</li>
                        <li>
                          Point Hermes at{" "}
                          <code className="rounded bg-white px-1.5 py-0.5 text-xs">http://localhost:3000/api/agent</code>
                          {" "}(Settings → Agents for token/status).
                        </li>
                        <li>
                          Prompt Hermes something like: search Xbook for this topic/URL, pull the bookmark via{" "}
                          <code className="rounded bg-white px-1.5 py-0.5 text-xs">resource=bookmarks</code>, then write a step-by-step
                          tutorial in Obsidian grounded in that post (cite the original link).
                        </li>
                      </ol>
                    </div>
                    <div className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4 space-y-2">
                      <p className="text-xs font-bold uppercase text-on-surface-variant">Example Hermes ask</p>
                      <pre className="overflow-x-auto rounded-lg bg-slate-950 p-3 text-xs leading-5 text-slate-100 whitespace-pre-wrap">{`Use the Xbook Agent API at http://localhost:3000/api/agent.
Search my bookmarks for the post I saved about [topic / author / phrase].
Read the matching bookmark (text + summary + tweet URL).
Write a practical tutorial in my Obsidian vault based on that xeet—expand steps, add caveats, keep the original link as the source.`}</pre>
                      <p className="text-sm text-on-surface-variant leading-6">
                        Hermes can list/search with{" "}
                        <code className="rounded bg-white px-1.5 py-0.5 text-xs">GET …?resource=bookmarks&amp;q=…</code>{" "}
                        and optionally append notes back with{" "}
                        <code className="rounded bg-white px-1.5 py-0.5 text-xs">appendBookmarkData</code>.
                      </p>
                    </div>
                  </div>
                  <p className="text-sm font-semibold text-primary">
                    Win: one bookmarked post becomes a full tutorial in your vault—no copy-paste archaeology.
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

            {/* Step 1: Connecting your accounts */}
            <section className="space-y-8">
              <div className="flex items-center gap-4">
                <span className="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-white font-bold">1</span>
                <h2 className="text-3xl font-bold">Connecting your accounts</h2>
              </div>
              <div className="space-y-4">
                <p className="text-on-surface-variant max-w-2xl leading-relaxed">
                  Open <Link href="/settings" className="text-primary hover:underline font-semibold">Settings</Link>{" "}
                  → <strong>Connections</strong>. Settings are stored in the local database; env vars are optional fallbacks for developers.
                </p>
                <div className="grid gap-6 md:grid-cols-2">
                  <div className="p-6 rounded-xl bg-surface-container-lowest border border-outline-variant/50 space-y-3">
                    <h3 className="font-bold text-lg text-primary">X integration</h3>
                    <p className="text-sm text-on-surface-variant leading-6">
                      Enter your X OAuth client ID (and secret if required), set the redirect URI, then click{" "}
                      <strong>Save &amp; Connect</strong>. Use <strong>Test connection</strong> or{" "}
                      <strong>Run diagnostics</strong> if sync fails.
                    </p>
                  </div>
                  <div className="p-6 rounded-xl bg-surface-container-lowest border border-outline-variant/50 space-y-3">
                    <h3 className="font-bold text-lg text-primary">YouTube integration</h3>
                    <p className="text-sm text-on-surface-variant leading-6">
                      Use <strong>Browse Google OAuth JSON</strong> to load a Google Cloud OAuth client file, confirm client ID/secret and redirect URI, then{" "}
                      <strong>Save &amp; Connect YouTube</strong>.
                    </p>
                  </div>
                </div>
                <div className="p-6 rounded-2xl bg-primary/5 border border-primary/20 space-y-2">
                  <p className="text-sm font-bold text-primary">Settings map</p>
                  <p className="text-sm text-on-surface-variant leading-6">
                    Tabs: <strong>Connections</strong> (X / YouTube) · <strong>AI</strong> (LLM) ·{" "}
                    <strong>Limits</strong> (caps, batch size, sounds) · <strong>Data</strong> (backup/restore) ·{" "}
                    <strong>Agents</strong> (local Agent API).
                  </p>
                </div>
              </div>
            </section>

            {/* Step 2: Configure your AI (LLM) */}
            <section className="space-y-8">
              <div className="flex items-center gap-4">
                <span className="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-white font-bold">2</span>
                <h2 className="text-3xl font-bold">Configure your AI (LLM)</h2>
              </div>
              <div className="space-y-6">
                <div className="rounded-2xl border border-amber-500/30 bg-amber-50/80 p-6 space-y-2">
                  <p className="text-sm font-bold text-amber-900">Why this matters</p>
                  <p className="text-sm text-on-surface-variant leading-6">
                    <strong>Enrich</strong> and <strong>semantic search</strong> need a working language model.
                    Without LLM settings, Sync can still import bookmarks, but summaries, tags, categories, and vector search will not run—or will fail in Processing with connection errors.
                  </p>
                </div>

                <p className="text-on-surface-variant max-w-2xl leading-relaxed">
                  Open <Link href="/settings" className="text-primary hover:underline font-semibold">Settings</Link>{" "}
                  → <strong>AI</strong> (section title: <strong>LLM configuration</strong>). Xbook talks to any{" "}
                  <strong>OpenAI-compatible</strong> chat/completions endpoint—local apps (LM Studio, Ollama)
                  or remote APIs. Use a preset button to fill sensible defaults, then set the exact model name
                  your server is serving. Save settings before testing.
                </p>

                <div className="grid gap-4 md:grid-cols-2">
                  <div className="rounded-xl border border-outline-variant/50 bg-surface-container-lowest p-6 space-y-3">
                    <h3 className="font-bold text-lg text-primary">LM Studio</h3>
                    <p className="text-sm text-on-surface-variant leading-6">
                      Start LM Studio, load a chat model, and enable the local server (OpenAI-compatible API).
                      In Settings, click <strong>LM Studio defaults</strong>, then set the model ID to match what you loaded.
                    </p>
                    <ul className="text-sm text-on-surface-variant leading-6 space-y-1.5 list-disc list-inside">
                      <li>
                        Base URL:{" "}
                        <code className="rounded bg-white px-1.5 py-0.5 text-xs">http://127.0.0.1:1234/v1</code>
                      </li>
                      <li>
                        API key:{" "}
                        <code className="rounded bg-white px-1.5 py-0.5 text-xs">lm-studio</code>{" "}
                        (placeholder is fine locally)
                      </li>
                      <li>Model: exact name shown in LM Studio for the loaded model</li>
                    </ul>
                  </div>
                  <div className="rounded-xl border border-outline-variant/50 bg-surface-container-lowest p-6 space-y-3">
                    <h3 className="font-bold text-lg text-primary">Ollama</h3>
                    <p className="text-sm text-on-surface-variant leading-6">
                      Install Ollama and pull a chat model (e.g. <code className="rounded bg-white px-1.5 py-0.5 text-xs">ollama pull llama3.2</code>).
                      Click <strong>Ollama defaults</strong>, set the chat model name, and pull an embedding model for search.
                    </p>
                    <ul className="text-sm text-on-surface-variant leading-6 space-y-1.5 list-disc list-inside">
                      <li>
                        Base URL:{" "}
                        <code className="rounded bg-white px-1.5 py-0.5 text-xs">http://127.0.0.1:11434/v1</code>
                      </li>
                      <li>
                        API key:{" "}
                        <code className="rounded bg-white px-1.5 py-0.5 text-xs">ollama</code>
                      </li>
                      <li>
                        Embedding model (recommended):{" "}
                        <code className="rounded bg-white px-1.5 py-0.5 text-xs">nomic-embed-text</code>
                      </li>
                    </ul>
                  </div>
                  <div className="rounded-xl border border-outline-variant/50 bg-surface-container-lowest p-6 space-y-3">
                    <h3 className="font-bold text-lg text-primary">Other local servers</h3>
                    <p className="text-sm text-on-surface-variant leading-6">
                      Presets also exist for <strong>vLLM</strong> (port 8000) and <strong>MLX</strong> model IDs.
                      Any host that exposes OpenAI-style <code className="rounded bg-white px-1.5 py-0.5 text-xs">/v1/chat/completions</code>{" "}
                      works if you set base URL, key, and model correctly.
                    </p>
                  </div>
                  <div className="rounded-xl border border-outline-variant/50 bg-surface-container-lowest p-6 space-y-3">
                    <h3 className="font-bold text-lg text-primary">Remote / OpenAI-style APIs</h3>
                    <p className="text-sm text-on-surface-variant leading-6">
                      Point the base URL at your provider&apos;s OpenAI-compatible endpoint, paste a real API key,
                      and use their model id (e.g. a hosted chat model plus a dedicated embedding model).
                      Keep concurrency low at first if you are rate-limited.
                    </p>
                  </div>
                </div>

                <div className="rounded-2xl bg-white p-6 shadow-sm border border-outline-variant/30 space-y-4">
                  <h3 className="text-lg font-bold text-on-surface">Fields you must get right</h3>
                  <div className="overflow-hidden rounded-xl border border-outline-variant/40">
                    <div className="grid grid-cols-1 gap-0 md:grid-cols-[180px_minmax(0,1fr)]">
                      {[
                        ["LLM base URL", "Endpoint root ending in /v1 (LM Studio :1234, Ollama :11434, vLLM :8000)."],
                        ["LLM API key", "Required by the client even for local servers; use the preset placeholder unless your host needs a real secret."],
                        ["LLM model", "Exact chat model id currently loaded/served—use Fetch models in Settings when available."],
                        ["Embedding model", "Separate model for semantic search vectors (e.g. nomic-embed-text). Do not reuse a chat model here."],
                        ["Embedding base URL", "Optional. Leave blank to reuse the LLM base URL. Set this when chat runs on vLLM/MLX and embeddings run on Ollama/LM Studio."],
                        ["Concurrency", "Parallel enrichment jobs. Local models usually work best at 1."],
                      ].map(([label, detail]) => (
                        <div
                          key={label}
                          className="contents"
                        >
                          <div className="border-t border-outline-variant/40 bg-surface-container-low px-4 py-3 text-sm font-bold text-on-surface md:border-r">
                            {label}
                          </div>
                          <div className="border-t border-outline-variant/40 px-4 py-3 text-sm text-on-surface-variant leading-6">
                            {detail}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                  <p className="text-sm text-on-surface-variant leading-6">
                    After saving, use <strong>Test LLM connection</strong> in Settings → AI. Only when that succeeds should you run{" "}
                    <strong>Process inbox</strong> (or Enrich under Advanced) on the Dashboard. Watch{" "}
                    <Link href="/processing" className="text-primary hover:underline font-semibold">Processing</Link>{" "}
                    if jobs fail—connection refused usually means the local server is not running or the port is wrong.
                  </p>
                </div>
              </div>
            </section>

            {/* Step 3: Process inbox */}
            <section className="space-y-8">
              <div className="flex items-center gap-4">
                <span className="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-white font-bold">3</span>
                <h2 className="text-3xl font-bold">Process inbox</h2>
              </div>
              <div className="space-y-6">
                <p className="text-on-surface-variant max-w-2xl leading-relaxed">
                  On the <Link href="/" className="text-primary hover:underline font-semibold">Dashboard</Link>,
                  each source tab (X or YouTube) has an <strong>Inbox</strong> card. Day-to-day you only need one control.
                </p>

                <div className="rounded-2xl bg-white p-6 shadow-sm border border-outline-variant/30 space-y-4">
                  <div className="flex flex-wrap items-center gap-3">
                    <span className="rounded-full bg-black px-4 py-1.5 text-sm font-semibold text-white">Process inbox</span>
                    <span className="text-xs font-bold uppercase tracking-wide text-emerald-800">Primary · recommended</span>
                  </div>
                  <p className="text-sm text-on-surface-variant leading-6">
                    One button that runs the full pipeline for the active tab:
                  </p>
                  <ol className="list-decimal list-inside space-y-2 text-sm text-on-surface-variant leading-6">
                    <li>
                      <strong>Sync / import</strong> — pull new bookmarks or saved videos from the platform (no LLM required).
                    </li>
                    <li>
                      <strong>Enrich</strong> — send items that still need a summary to your configured LLM for summary, category, and tags (needs step 2).
                    </li>
                    <li>
                      <strong>Index embeddings</strong> — generate vectors for semantic search when an embedding model is configured.
                    </li>
                  </ol>
                  <p className="text-sm text-on-surface-variant leading-6">
                    Progress and errors show under the button and on the{" "}
                    <Link href="/processing" className="text-primary hover:underline font-semibold">Processing</Link> page.
                  </p>
                </div>

                <div className="rounded-2xl border border-outline-variant/40 bg-surface-container-lowest p-6 space-y-4">
                  <h3 className="text-lg font-bold text-on-surface">Advanced actions</h3>
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
                        Checkbox to re-run enrichment on items that already have summaries (e.g. after changing prompts or models).
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </section>

            {/* Step 4: The Library & Semantic Search */}
            <section className="space-y-8">
              <div className="flex items-center gap-4">
                <span className="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-white font-bold">4</span>
                <h2 className="text-3xl font-bold">The Library & Semantic Search</h2>
              </div>
              <div className="space-y-6">
                <p className="text-on-surface-variant max-w-2xl leading-relaxed">
                  The nav has separate <strong>X Library</strong> and <strong>YouTube Library</strong> entries (both open{" "}
                  <Link href="/bookmarks" className="text-primary hover:underline font-semibold">/bookmarks</Link>{" "}
                  with a source filter). Use search, category, status (pending / summarized), videos-only, and folders to narrow the list.
                </p>
                <div className="p-6 rounded-2xl bg-primary/5 border border-primary/20 space-y-4">
                  <h4 className="font-bold flex items-center gap-2">
                    What is &quot;Semantic Search&quot;?
                    <span className="text-[10px] bg-primary/10 text-primary px-1 rounded font-bold uppercase">AI</span>
                  </h4>
                  <p className="text-sm leading-6 italic text-on-surface-variant">
                    Check the <strong>Semantic Search</strong> box on the Library filter bar, then search for{" "}
                    <strong>ideas</strong> instead of exact words. Example: &quot;how to build a house&quot; can surface architecture links that never used the word &quot;house&quot;.
                  </p>
                  <p className="text-sm leading-6 text-on-surface-variant">
                    This needs an <strong>embedding model</strong> (and usually successful enrichment so items have summaries).
                    Configure it under Settings → <strong>AI</strong>. If chat runs on a server without embeddings (common with some vLLM setups),
                    set a separate embedding base URL—often Ollama with <code className="rounded bg-white px-1.5 py-0.5 text-xs">nomic-embed-text</code>.
                  </p>
                </div>
                <div className="grid gap-4 md:grid-cols-2">
                  <div className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-5 space-y-2">
                    <h3 className="font-bold text-on-surface">
                      <Link href="/folders" className="text-primary hover:underline">Folders</Link>
                    </h3>
                    <p className="text-sm text-on-surface-variant leading-6">
                      Browse and sync platform folders / playlists used to organize imported items.
                    </p>
                  </div>
                  <div className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-5 space-y-2">
                    <h3 className="font-bold text-on-surface">
                      <Link href="/processing" className="text-primary hover:underline">Processing</Link>
                    </h3>
                    <p className="text-sm text-on-surface-variant leading-6">
                      Audit trail for sync and enrichment runs—open this when Process inbox fails or hangs.
                    </p>
                  </div>
                </div>
              </div>
            </section>
          </div>
        ) : (
          <div className="space-y-16 animate-fadeIn">
            {/* Step 1: Developer Installation & Setup */}
            <section className="space-y-8">
              <div className="flex items-center gap-4">
                <span className="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-white font-bold">1</span>
                <h2 className="text-3xl font-bold">Development Environment Setup</h2>
              </div>
              <div className="rounded-2xl bg-white p-8 shadow-sm border border-outline-variant/30 space-y-6">
                <p className="text-on-surface-variant leading-relaxed">
                  Follow these steps to initialize the database and install dependencies:
                </p>
                <div className="space-y-6">
                  <div className="flex gap-4">
                    <div className="w-1 bg-primary rounded-full shrink-0" />
                    <div className="space-y-2 flex-1">
                      <p className="font-bold text-base text-primary">1. Install Packages & Migrate Schema</p>
                      <p className="text-sm text-on-surface-variant leading-6">
                        Run package installations and Prisma schema migrations to set up the local SQLite database:
                      </p>
                      <pre className="mt-2 overflow-x-auto rounded-lg bg-slate-950 p-3 text-xs text-slate-100 font-mono">
                        npm install{"\n"}
                        npx prisma migrate dev
                      </pre>
                    </div>
                  </div>

                  <div className="flex gap-4">
                    <div className="w-1 bg-primary rounded-full shrink-0" />
                    <div className="space-y-2 flex-1">
                      <p className="font-bold text-base text-primary">2. Environment variables (optional fallbacks)</p>
                      <p className="text-sm text-on-surface-variant leading-6">
                        Most config lives in <strong>Settings</strong> (SQLite). Env vars seed or override when Settings fields are empty.
                        Create <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs text-on-surface">.env.local</code> if useful:
                      </p>
                      <pre className="mt-2 overflow-x-auto rounded-lg bg-slate-950 p-3 text-xs text-slate-100 font-mono">
                        DATABASE_URL=&quot;file:./dev.db&quot;{"\n"}
                        OPENAI_BASE_URL=&quot;http://127.0.0.1:1234/v1&quot;{"\n"}
                        OPENAI_API_KEY=&quot;lm-studio&quot;{"\n"}
                        OPENAI_MODEL=&quot;your-model-name&quot;{"\n"}
                        X_CLIENT_ID=&quot;your-x-client-id&quot;{"\n"}
                        YT_CLIENT_ID=&quot;your-youtube-client-id&quot;{"\n"}
                        AGENT_API_TOKEN=&quot;optional-for-agent-writes&quot;
                      </pre>
                    </div>
                  </div>

                  <div className="flex gap-4">
                    <div className="w-1 bg-primary rounded-full shrink-0" />
                    <div className="space-y-2 flex-1">
                      <p className="font-bold text-base text-primary">3. Run, test, and package</p>
                      <p className="text-sm text-on-surface-variant leading-6">
                        Start the web app, run unit tests, or build the desktop bundle:
                      </p>
                      <pre className="mt-2 overflow-x-auto rounded-lg bg-slate-950 p-3 text-xs text-slate-100 font-mono">
                        npm run dev{"\n"}
                        npm run test{"\n"}
                        npm run build:desktop
                      </pre>
                    </div>
                  </div>
                </div>
              </div>
            </section>

            {/* Step 2: Agent API Endpoints */}
            <section className="space-y-8">
              <div className="flex items-center gap-4">
                <span className="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-white font-bold">2</span>
                <h2 className="text-3xl font-bold">Agent API Endpoints</h2>
              </div>
              <div className="space-y-6">
                <div className="rounded-2xl border border-outline-variant/30 bg-white p-6 shadow-sm">
                  <p className="max-w-2xl text-sm leading-6 text-on-surface-variant">
                    Local agents can use <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs text-on-surface">/api/agent</code> to retrieve data from Xbook and update or append bookmark data. The endpoint is designed for local automation, not for public internet exposure.
                  </p>
                  <div className="mt-4 grid gap-4 md:grid-cols-2">
                    <div className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4">
                      <h3 className="font-bold text-primary">Base URL</h3>
                      <pre className="mt-3 overflow-x-auto rounded-lg bg-slate-950 p-3 text-xs text-slate-100">http://localhost:3000/api/agent</pre>
                    </div>
                    <div className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4">
                      <h3 className="font-bold text-primary">Authentication</h3>
                      <p className="mt-3 text-sm leading-6 text-on-surface-variant">
                        Without <code className="rounded bg-white px-1.5 py-0.5 text-xs">AGENT_API_TOKEN</code>, requests are accepted only from localhost. When the token is set, send either <code className="rounded bg-white px-1.5 py-0.5 text-xs">Authorization: Bearer &lt;token&gt;</code> or <code className="rounded bg-white px-1.5 py-0.5 text-xs">x-agent-token: &lt;token&gt;</code>.
                      </p>
                    </div>
                  </div>
                </div>

                <div className="rounded-2xl border border-outline-variant/30 bg-white p-6 shadow-sm">
                  <h3 className="text-xl font-bold">Read endpoints</h3>
                  <div className="mt-4 overflow-hidden rounded-xl border border-outline-variant/40">
                    <div className="grid grid-cols-[76px_minmax(0,1fr)] bg-surface-container-low px-4 py-3 text-xs font-bold uppercase text-on-surface-variant md:grid-cols-[76px_minmax(0,1fr)_220px]">
                      <span>Method</span>
                      <span>Endpoint</span>
                      <span className="hidden md:block">Purpose</span>
                    </div>
                    {[
                      ["/api/agent", "Endpoint index and examples"],
                      ["/api/agent?resource=bookmarks&pageSize=50", "List, search, and filter bookmarks"],
                      ["/api/agent?resource=bookmark&id=<bookmarkId>", "Retrieve one bookmark by ID"],
                      ["/api/agent?resource=folders", "List folders and playlist folders"],
                      ["/api/agent?resource=runs&take=50", "Inspect processing run summaries"],
                    ].map(([endpoint, purpose]) => (
                      <div key={endpoint} className="grid min-w-0 grid-cols-[76px_minmax(0,1fr)] gap-3 border-t border-outline-variant/40 px-4 py-3 text-sm md:grid-cols-[76px_minmax(0,1fr)_220px]">
                        <span className="font-mono text-xs font-bold text-emerald-700">GET</span>
                        <code className="block min-w-0 overflow-x-auto whitespace-nowrap rounded bg-surface-container-low px-2 py-1 text-xs text-on-surface">{endpoint}</code>
                        <span className="text-sm text-on-surface-variant">{purpose}</span>
                      </div>
                    ))}
                  </div>
                  <pre className="mt-4 overflow-x-auto rounded-xl bg-slate-950 p-4 text-xs leading-6 text-slate-100">{`curl -sS 'http://localhost:3000/api/agent?resource=bookmarks&pageSize=25&q=ai'`}</pre>
                </div>

                <div className="rounded-2xl border border-outline-variant/30 bg-white p-6 shadow-sm">
                  <h3 className="text-xl font-bold">Write actions</h3>
                  <p className="mt-2 max-w-2xl text-sm leading-6 text-on-surface-variant">
                    Send write requests as JSON with <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs">POST /api/agent</code>. Existing bookmarks are updated in place, and append operations preserve existing summaries and tags.
                  </p>
                  <div className="mt-4 grid gap-4 md:grid-cols-2">
                    {[
                      ["upsertBookmark", "Create or replace local bookmark fields."],
                      ["updateBookmark", "Patch selected fields such as summary, category, tags, readAt, or folderId."],
                      ["appendBookmarkData", "Append summary text, merge tags, or append mediaDescription notes."],
                      ["upsertFolder", "Create or rename a bookmark folder."],
                    ].map(([action, purpose]) => (
                      <div key={action} className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4">
                        <code className="rounded bg-white px-2 py-1 text-xs font-bold text-on-surface">{action}</code>
                        <p className="mt-3 text-sm leading-6 text-on-surface-variant">{purpose}</p>
                      </div>
                    ))}
                  </div>
                  <pre className="mt-4 overflow-x-auto rounded-xl bg-slate-950 p-4 text-xs leading-6 text-slate-100">{`curl -sS -X POST 'http://localhost:3000/api/agent' \\
  -H 'content-type: application/json' \\
  --data '{"action":"appendBookmarkData","bookmarkId":"<bookmarkId>","data":{"tags":["reviewed"],"summary":"Agent note."}}'`}</pre>
                </div>

                <div className="rounded-2xl border border-primary/20 bg-primary/5 p-6">
                  <h3 className="text-lg font-bold text-primary">Payload reference</h3>
                  <div className="mt-4 grid gap-4 md:grid-cols-2">
                    <div>
                      <p className="text-sm font-bold uppercase text-on-surface">Bookmark fields</p>
                      <p className="mt-2 text-sm leading-6 text-on-surface-variant">
                        Common writable fields include <code>source</code>, <code>tweetUrl</code>, <code>text</code>, <code>authorName</code>, <code>authorUsername</code>, <code>createdAt</code>, <code>summary</code>, <code>category</code>, <code>tags</code>, <code>folderId</code>, <code>readAt</code>, <code>mediaDescription</code>, and <code>enrichmentError</code>.
                      </p>
                    </div>
                    <div>
                      <p className="text-sm font-bold uppercase text-on-surface">Response shape</p>
                      <p className="mt-2 text-sm leading-6 text-on-surface-variant">
                        Successful requests return <code>{"{ ok: true, ... }"}</code>. Validation or authorization failures return <code>{"{ ok: false, error }"}</code> with an HTTP error status.
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </section>

            {/* Step 3: Troubleshooting Native Dependencies */}
            <section className="space-y-8">
              <div className="flex items-center gap-4">
                <span className="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-white font-bold">3</span>
                <h2 className="text-3xl font-bold">Troubleshooting Native Dependencies</h2>
              </div>
              <div className="rounded-2xl bg-white p-8 shadow-sm border border-outline-variant/30 space-y-4">
                <p className="text-sm text-on-surface-variant leading-6">
                  If you switch or upgrade Node.js versions and encounter a <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs text-on-surface">better_sqlite3.node</code> or <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs text-on-surface">NODE_MODULE_VERSION</code> error, rebuild the native bindings:
                </p>
                <pre className="overflow-x-auto rounded-lg bg-slate-950 p-4 text-sm text-slate-100 font-mono">
                  npm rebuild better-sqlite3
                </pre>
              </div>
            </section>
          </div>
        )}

        {/* Footer */}
        <footer className="pt-16 border-t border-outline-ghost flex flex-col items-center gap-6">
          <div className="text-center space-y-2">
            <p className="font-bold italic">&quot;Never lose a digital insight again.&quot;</p>
          </div>
          <Link href="/" className="rounded-full bg-black px-10 py-4 text-lg font-bold text-white shadow-xl transition hover:scale-105 active:scale-95">
            Back to Dashboard
          </Link>
        </footer>
      </div>
    </main>
  );
}
