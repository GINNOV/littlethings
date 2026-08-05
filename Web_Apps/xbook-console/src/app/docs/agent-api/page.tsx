import Link from "next/link";
import { DocsPageShell } from "../DocsPageShell";

export default function DocsAgentApiPage() {
  return (
    <DocsPageShell
      title="Agent API"
      description="Local HTTP API for Hermes, scripts, and tools to search and update bookmarks. Not for public internet exposure."
    >
      <div className="space-y-8">
        <div className="rounded-2xl border border-outline-variant/30 bg-white p-6 shadow-sm">
          <p className="max-w-2xl text-sm leading-6 text-on-surface-variant">
            Local agents (Hermes, scripts, MCP-style tools) use{" "}
            <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs text-on-surface">/api/agent</code>{" "}
            to search and update bookmarks. The same surface is summarized under{" "}
            <Link href="/settings" className="text-primary hover:underline font-semibold">
              Settings → Agents
            </Link>
            . For a full recipe, see{" "}
            <Link href="/docs/scenarios#hermes-obsidian" className="text-primary hover:underline font-semibold">
              Hermes + Obsidian
            </Link>
            .
          </p>
          <div className="mt-4 grid gap-4 md:grid-cols-2">
            <div className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4">
              <h2 className="font-bold text-primary">Base URL</h2>
              <pre className="mt-3 overflow-x-auto rounded-lg bg-slate-950 p-3 text-xs text-slate-100">
                http://localhost:3000/api/agent
              </pre>
            </div>
            <div className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4">
              <h2 className="font-bold text-primary">Authentication</h2>
              <p className="mt-3 text-sm leading-6 text-on-surface-variant">
                Without <code className="rounded bg-white px-1.5 py-0.5 text-xs">AGENT_API_TOKEN</code>, only
                localhost is accepted. When the token is set, every request must send{" "}
                <code className="rounded bg-white px-1.5 py-0.5 text-xs">Authorization: Bearer &lt;token&gt;</code> or{" "}
                <code className="rounded bg-white px-1.5 py-0.5 text-xs">x-agent-token: &lt;token&gt;</code>{" "}
                (localhost alone is not enough).
              </p>
            </div>
          </div>
        </div>

        <div className="rounded-2xl border border-outline-variant/30 bg-white p-6 shadow-sm">
          <h2 className="text-xl font-bold">Read endpoints</h2>
          <div className="mt-4 overflow-hidden rounded-xl border border-outline-variant/40">
            <div className="grid grid-cols-[76px_minmax(0,1fr)] bg-surface-container-low px-4 py-3 text-xs font-bold uppercase text-on-surface-variant md:grid-cols-[76px_minmax(0,1fr)_220px]">
              <span>Method</span>
              <span>Endpoint</span>
              <span className="hidden md:block">Purpose</span>
            </div>
            {[
              ["/api/agent", "Index / help (lists reads, writes, auth)"],
              ["/api/agent?resource=bookmarks&…", "List, search, and filter bookmarks"],
              ["/api/agent?resource=bookmark&id=<id>", "One bookmark by ID"],
              ["/api/agent?resource=folders", "List folders / playlists"],
              ["/api/agent?resource=runs&take=50", "Processing run summaries"],
            ].map(([endpoint, purpose]) => (
              <div
                key={endpoint}
                className="grid min-w-0 grid-cols-[76px_minmax(0,1fr)] gap-3 border-t border-outline-variant/40 px-4 py-3 text-sm md:grid-cols-[76px_minmax(0,1fr)_220px]"
              >
                <span className="font-mono text-xs font-bold text-emerald-700">GET</span>
                <code className="block min-w-0 overflow-x-auto whitespace-nowrap rounded bg-surface-container-low px-2 py-1 text-xs text-on-surface">
                  {endpoint}
                </code>
                <span className="text-sm text-on-surface-variant">{purpose}</span>
              </div>
            ))}
          </div>
          <p className="mt-4 text-sm text-on-surface-variant leading-6">
            Bookmark query params:{" "}
            <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs">q</code>,{" "}
            <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs">source</code>{" "}
            <span className="text-on-surface-variant/80">(x | yt)</span>,{" "}
            <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs">status</code>,{" "}
            <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs">category</code>,{" "}
            <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs">folderId</code>,{" "}
            <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs">page</code>,{" "}
            <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs">pageSize</code>,{" "}
            <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs">video=true</code>,{" "}
            <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs">semantic=true</code>. Runs also
            accept <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs">source</code>,{" "}
            <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs">status</code>,{" "}
            <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs">type</code>,{" "}
            <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs">take</code>.
          </p>
          <pre className="mt-4 overflow-x-auto rounded-xl bg-slate-950 p-4 text-xs leading-6 text-slate-100">{`# Keyword search
curl -sS 'http://localhost:3000/api/agent?resource=bookmarks&pageSize=25&q=ai&source=x'

# Semantic search (needs embeddings)
curl -sS 'http://localhost:3000/api/agent?resource=bookmarks&semantic=true&q=local+llm+setup&pageSize=10'`}</pre>
        </div>

        <div className="rounded-2xl border border-outline-variant/30 bg-white p-6 shadow-sm">
          <h2 className="text-xl font-bold">Write actions</h2>
          <p className="mt-2 max-w-2xl text-sm leading-6 text-on-surface-variant">
            Send JSON with <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs">POST /api/agent</code>
            . Updates are in place; append merges tags and appends summary / media notes.
          </p>
          <div className="mt-4 grid gap-4 md:grid-cols-2">
            {[
              ["upsertBookmark", "Create or replace local bookmark fields (requires id + tweetUrl)."],
              ["updateBookmark", "Patch fields such as summary, category, tags, readAt, or folderId."],
              ["appendBookmarkData", "Append summary text, merge tags, or append mediaDescription notes."],
              ["upsertFolder", "Create or rename a bookmark folder."],
            ].map(([action, purpose]) => (
              <div
                key={action}
                className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4"
              >
                <code className="rounded bg-white px-2 py-1 text-xs font-bold text-on-surface">{action}</code>
                <p className="mt-3 text-sm leading-6 text-on-surface-variant">{purpose}</p>
              </div>
            ))}
          </div>
          <pre className="mt-4 overflow-x-auto rounded-xl bg-slate-950 p-4 text-xs leading-6 text-slate-100">{`curl -sS -X POST 'http://localhost:3000/api/agent' \\
  -H 'content-type: application/json' \\
  -H 'Authorization: Bearer $AGENT_API_TOKEN' \\
  --data '{"action":"appendBookmarkData","bookmarkId":"<bookmarkId>","data":{"tags":["reviewed"],"summary":"Agent note."}}'`}</pre>
        </div>

        <div className="rounded-2xl border border-primary/20 bg-primary/5 p-6">
          <h2 className="text-lg font-bold text-primary">Payload reference</h2>
          <div className="mt-4 grid gap-4 md:grid-cols-2">
            <div>
              <p className="text-sm font-bold uppercase text-on-surface">Bookmark fields</p>
              <p className="mt-2 text-sm leading-6 text-on-surface-variant">
                Common writable fields include <code>source</code>, <code>tweetUrl</code>, <code>text</code>,{" "}
                <code>authorName</code>, <code>authorUsername</code>, <code>createdAt</code>, <code>summary</code>,{" "}
                <code>category</code>, <code>tags</code>, <code>folderId</code>, <code>readAt</code>,{" "}
                <code>mediaDescription</code>, and <code>enrichmentError</code>.
              </p>
            </div>
            <div>
              <p className="text-sm font-bold uppercase text-on-surface">Response shape</p>
              <p className="mt-2 text-sm leading-6 text-on-surface-variant">
                Success: <code>{"{ ok: true, ... }"}</code>. Failures: <code>{"{ ok: false, error }"}</code> with an
                HTTP error status.
              </p>
            </div>
          </div>
        </div>
      </div>
    </DocsPageShell>
  );
}
