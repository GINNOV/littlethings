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
              Desktop User Experience
            </button>
            <button
              onClick={() => setActiveTab("developer")}
              className={`rounded-lg px-6 py-2.5 text-sm font-semibold transition-all cursor-pointer ${
                activeTab === "developer"
                  ? "bg-white text-primary shadow-sm"
                  : "text-on-surface-variant hover:text-on-surface"
              }`}
            >
              Developer Experience
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

            {/* Step 1: Simplified Setup */}
            <section className="space-y-8">
              <div className="flex items-center gap-4">
                <span className="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-white font-bold">1</span>
                <h2 className="text-3xl font-bold">Quick Start</h2>
              </div>
              <div className="rounded-2xl bg-white p-8 shadow-sm border border-outline-variant/30 space-y-6">
                <p className="text-on-surface-variant leading-relaxed">
                  Start Xbook locally on your computer using a single command:
                </p>
                <div className="space-y-4">
                  <pre className="overflow-x-auto rounded-lg bg-slate-950 p-4 text-sm text-slate-100 font-mono">
                    npm run dev
                  </pre>
                  <p className="text-sm text-on-surface-variant leading-6">
                    Then, open <a href="http://localhost:3000" className="text-primary hover:underline font-semibold" target="_blank" rel="noreferrer">http://localhost:3000</a> in your web browser. 
                    Everything—from account connections to LLM configuration—can be managed directly within the web application interface.
                  </p>
                </div>
              </div>
            </section>

            {/* Step 2: Connecting your accounts */}
            <section className="space-y-8">
              <div className="flex items-center gap-4">
                <span className="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-white font-bold">2</span>
                <h2 className="text-3xl font-bold">Connecting your accounts</h2>
              </div>
              <div className="space-y-4">
                <p className="text-on-surface-variant">
                   Start in the <Link href="/settings" className="text-primary hover:underline font-semibold">Settings</Link> to connect your data sources.
                </p>
                <div className="grid gap-6 md:grid-cols-2">
                  <div className="p-6 rounded-xl bg-surface-container-lowest border border-outline-variant/50 space-y-3">
                    <h3 className="font-bold text-lg text-primary">Secure X Connection</h3>
                    <p className="text-sm text-on-surface-variant leading-6">
                      Click &quot;Connect X&quot; to securely link your bookmarks.
                    </p>
                  </div>
                  <div className="p-6 rounded-xl bg-surface-container-lowest border border-outline-variant/50 space-y-3">
                    <h3 className="font-bold text-lg text-primary">YouTube Credentials</h3>
                    <p className="text-sm text-on-surface-variant leading-6">
                      Upload your Client JSON file to unlock your playlists.
                    </p>
                  </div>
                </div>
                <div className="p-6 rounded-2xl bg-primary/5 border border-primary/20 space-y-2">
                  <p className="text-sm font-bold text-primary">💡 Configuration Tip</p>
                  <p className="text-sm text-on-surface-variant leading-6">
                    You can also configure API keys directly via environment variables like <code className="rounded bg-white px-1.5 py-0.5 text-xs text-on-surface">X_CLIENT_ID</code> and <code className="rounded bg-white px-1.5 py-0.5 text-xs text-on-surface">YT_CLIENT_ID</code> in your <code className="rounded bg-white px-1.5 py-0.5 text-xs text-on-surface">.env.local</code>.
                  </p>
                </div>
              </div>
            </section>

            {/* Step 3: Sync & Summarize */}
            <section className="space-y-8">
              <div className="flex items-center gap-4">
                <span className="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-white font-bold">3</span>
                <h2 className="text-3xl font-bold">Sync & Summarize</h2>
              </div>
              <div className="space-y-6 max-w-2xl">
                <p className="text-on-surface-variant">
                  Once connected, go back to the <Link href="/" className="text-primary hover:underline font-semibold">Dashboard</Link> to bring your content to life.
                </p>
                <div className="space-y-4">
                  <div className="flex gap-4">
                    <div className="w-1 bg-emerald-500 rounded-full" />
                    <div>
                      <p className="font-bold text-sm uppercase text-emerald-800">Step A: Sync</p>
                      <p className="text-sm text-on-surface-variant">Fetches the latest links from your accounts.</p>
                    </div>
                  </div>
                  <div className="flex gap-4">
                    <div className="w-1 bg-primary rounded-full" />
                    <div>
                      <p className="font-bold text-sm uppercase text-primary">Step B: Enrich</p>
                      <p className="text-sm text-on-surface-variant">This triggers the &quot;Magic&quot; where the AI reads and summarizes every item.</p>
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
                <p className="text-on-surface-variant max-w-2xl">
                  Your <Link href="/bookmarks" className="text-primary hover:underline font-semibold">Library</Link> is where you explore your knowledge.
                </p>
                <div className="p-6 rounded-2xl bg-primary/5 border border-primary/20 space-y-4">
                  <h4 className="font-bold flex items-center gap-2">
                    What is &quot;Semantic Search&quot;?
                    <span className="text-[10px] bg-primary/10 text-primary px-1 rounded font-bold uppercase">AI</span>
                  </h4>
                  <p className="text-sm leading-6 italic text-on-surface-variant">
                    Instead of searching for exact words, you can search for <strong>ideas</strong>. 
                    Search for &quot;how to build a house&quot; and Xbook will find architecture and construction links, even without the word &quot;house&quot;.
                  </p>
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
                      <p className="font-bold text-base text-primary">2. Set Up Environment Variables</p>
                      <p className="text-sm text-on-surface-variant leading-6">
                        Create a <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs text-on-surface">.env.local</code> in the root folder with configuration variables:
                      </p>
                      <pre className="mt-2 overflow-x-auto rounded-lg bg-slate-950 p-3 text-xs text-slate-100 font-mono">
                        DATABASE_URL=&quot;file:./dev.db&quot;{"\n"}
                        OPENAI_BASE_URL=&quot;http://localhost:1234/v1&quot; # LM Studio, Ollama, etc.{"\n"}
                        OPENAI_API_KEY=&quot;lm-studio&quot;{"\n"}
                        OPENAI_MODEL=&quot;your-model-name&quot;{"\n"}
                        X_CLIENT_ID=&quot;your-x-client-id&quot;{"\n"}
                        YT_CLIENT_ID=&quot;your-youtube-client-id&quot;
                      </pre>
                    </div>
                  </div>

                  <div className="flex gap-4">
                    <div className="w-1 bg-primary rounded-full shrink-0" />
                    <div className="space-y-2 flex-1">
                      <p className="font-bold text-base text-primary">3. Build & Run Tests</p>
                      <p className="text-sm text-on-surface-variant leading-6">
                        Verify your setup by running the test suite:
                      </p>
                      <pre className="mt-2 overflow-x-auto rounded-lg bg-slate-950 p-3 text-xs text-slate-100 font-mono">
                        npm run test
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
