import Link from "next/link";
import { DocsPageShell } from "../DocsPageShell";

export default function DocsLlmPage() {
  return (
    <DocsPageShell
      title="Configure your AI (LLM)"
      description="Enrich and semantic search need a working language model. Point Xbook at LM Studio, Ollama, vLLM, or any OpenAI-compatible endpoint."
    >
      <div className="space-y-8">
        <div className="rounded-2xl border border-amber-500/30 bg-amber-50/80 p-6 space-y-2">
          <p className="text-sm font-bold text-amber-900">Why this matters</p>
          <p className="text-sm text-on-surface-variant leading-6">
            <strong>Enrich</strong> and <strong>semantic search</strong> need a working language model. Without LLM
            settings, Sync can still import bookmarks, but summaries, tags, categories, and vector search will not
            run—or will fail in Processing with connection errors.
          </p>
        </div>

        <p className="text-on-surface-variant max-w-2xl leading-relaxed">
          Open{" "}
          <Link href="/settings" className="text-primary hover:underline font-semibold">
            Settings
          </Link>{" "}
          → <strong>AI</strong> (section title: <strong>LLM configuration</strong>). Xbook talks to any{" "}
          <strong>OpenAI-compatible</strong> chat/completions endpoint—local apps (LM Studio, Ollama) or remote APIs.
          Use a preset button to fill sensible defaults, then set the exact model name your server is serving. Save
          settings before testing.
        </p>

        <div className="grid gap-4 md:grid-cols-2">
          <div className="rounded-xl border border-outline-variant/50 bg-surface-container-lowest p-6 space-y-3">
            <h2 className="font-bold text-lg text-primary">LM Studio</h2>
            <p className="text-sm text-on-surface-variant leading-6">
              Start LM Studio, load a chat model, and enable the local server (OpenAI-compatible API). In Settings,
              click <strong>LM Studio</strong>, then set the model ID to match what you loaded.
            </p>
            <ul className="text-sm text-on-surface-variant leading-6 space-y-1.5 list-disc list-inside">
              <li>
                Base URL:{" "}
                <code className="rounded bg-white px-1.5 py-0.5 text-xs">http://127.0.0.1:1234/v1</code>
              </li>
              <li>
                API key: <code className="rounded bg-white px-1.5 py-0.5 text-xs">lm-studio</code> (placeholder is
                fine locally)
              </li>
              <li>Model: exact name shown in LM Studio for the loaded model</li>
            </ul>
          </div>
          <div className="rounded-xl border border-outline-variant/50 bg-surface-container-lowest p-6 space-y-3">
            <h2 className="font-bold text-lg text-primary">Ollama</h2>
            <p className="text-sm text-on-surface-variant leading-6">
              Install Ollama and pull a chat model (e.g.{" "}
              <code className="rounded bg-white px-1.5 py-0.5 text-xs">ollama pull llama3.2</code>). Click{" "}
              <strong>Ollama</strong>, set the chat model name, and pull an embedding model for search.
            </p>
            <ul className="text-sm text-on-surface-variant leading-6 space-y-1.5 list-disc list-inside">
              <li>
                Base URL:{" "}
                <code className="rounded bg-white px-1.5 py-0.5 text-xs">http://127.0.0.1:11434/v1</code>
              </li>
              <li>
                API key: <code className="rounded bg-white px-1.5 py-0.5 text-xs">ollama</code>
              </li>
              <li>
                Embedding model (recommended):{" "}
                <code className="rounded bg-white px-1.5 py-0.5 text-xs">nomic-embed-text</code>
              </li>
            </ul>
          </div>
          <div className="rounded-xl border border-outline-variant/50 bg-surface-container-lowest p-6 space-y-3">
            <h2 className="font-bold text-lg text-primary">REMOTE</h2>
            <p className="text-sm text-on-surface-variant leading-6">
              High-concurrency OpenAI-compatible vLLM on a LAN or remote host. Click <strong>REMOTE</strong> for a
              starter layout (example: <code className="rounded bg-white px-1.5 py-0.5 text-xs">gemma-4-26b</code>,
              concurrency <strong>32</strong>), then edit the base URL and model for your server. Embeddings stay on
              local Ollama by default.
            </p>
            <ul className="text-sm text-on-surface-variant leading-6 space-y-1.5 list-disc list-inside">
              <li>
                Example base URL:{" "}
                <code className="rounded bg-white px-1.5 py-0.5 text-xs">http://192.168.0.69:8000/v1</code>
              </li>
              <li>
                Example model: <code className="rounded bg-white px-1.5 py-0.5 text-xs">gemma-4-26b</code>
              </li>
              <li>
                Keep embedding base URL on Ollama/LM Studio — chat vLLM often has no embeddings endpoint.
              </li>
            </ul>
          </div>
          <div className="rounded-xl border border-outline-variant/50 bg-surface-container-lowest p-6 space-y-3">
            <h2 className="font-bold text-lg text-primary">Other local servers</h2>
            <p className="text-sm text-on-surface-variant leading-6">
              A <strong>vLLM (localhost)</strong> preset is also available. Any host that exposes OpenAI-style{" "}
              <code className="rounded bg-white px-1.5 py-0.5 text-xs">/v1/chat/completions</code> works if you set
              base URL, key, and model correctly.
            </p>
          </div>
          <div className="rounded-xl border border-outline-variant/50 bg-surface-container-lowest p-6 space-y-3 md:col-span-2">
            <h2 className="font-bold text-lg text-primary">Remote / OpenAI-style APIs</h2>
            <p className="text-sm text-on-surface-variant leading-6">
              Point the base URL at your provider&apos;s OpenAI-compatible endpoint, paste a real API key, and use
              their model id (e.g. a hosted chat model plus a dedicated embedding model). Keep concurrency low at
              first if you are rate-limited.
            </p>
          </div>
        </div>

        <div className="rounded-2xl bg-white p-6 shadow-sm border border-outline-variant/30 space-y-4">
          <h2 className="text-lg font-bold text-on-surface">Fields you must get right</h2>
          <div className="overflow-hidden rounded-xl border border-outline-variant/40">
            <div className="grid grid-cols-1 gap-0 md:grid-cols-[180px_minmax(0,1fr)]">
              {[
                [
                  "LLM base URL",
                  "Endpoint root ending in /v1 (LM Studio :1234, Ollama :11434, vLLM :8000).",
                ],
                [
                  "LLM API key",
                  "Required by the client even for local servers; use the preset placeholder unless your host needs a real secret.",
                ],
                [
                  "LLM model",
                  "Exact chat model id currently loaded/served—use Fetch models in Settings when available.",
                ],
                [
                  "Embedding model",
                  "Separate model for semantic search vectors (e.g. nomic-embed-text). Do not reuse a chat model here.",
                ],
                [
                  "Embedding base URL",
                  "Optional. Leave blank to reuse the LLM base URL. Set this when chat runs on vLLM and embeddings run on Ollama/LM Studio. Chat-only servers (many vLLM setups) return 404 on /v1/embeddings if you leave this blank.",
                ],
                [
                  "Concurrency",
                  "Parallel enrichment jobs (1–32). Use 1 for most local models; REMOTE / high-concurrency vLLM can use up to 32.",
                ],
              ].map(([label, detail]) => (
                <div key={label} className="contents">
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
            After saving, use <strong>Test LLM connection</strong> in Settings → AI. Only when that succeeds should
            you run <strong>Process inbox</strong> (or Enrich under Advanced) on the Dashboard. Watch{" "}
            <Link href="/processing" className="text-primary hover:underline font-semibold">
              Processing
            </Link>{" "}
            if jobs fail—connection refused usually means the local server is not running or the port is wrong.
          </p>
        </div>

        <div className="rounded-2xl bg-white p-6 shadow-sm border border-outline-variant/30 space-y-4">
          <h2 className="text-lg font-bold text-on-surface">Advanced: prompts &amp; thinking</h2>
          <p className="text-sm text-on-surface-variant leading-6">
            Open <strong>Show advanced</strong> under Settings → AI. These controls shape every enrichment call. They
            work the same for LM Studio, Ollama, and REMOTE—you do not need a different prompt just because the model
            runs on a LAN box.
          </p>

          <div className="rounded-xl border border-outline-variant/40 bg-surface-container-lowest p-4 space-y-2">
            <p className="text-sm font-bold text-on-surface">How each request is built</p>
            <ol className="list-decimal list-inside text-sm text-on-surface-variant leading-6 space-y-1">
              <li>
                <strong>System message</strong> — your <strong>LLM system prompt</strong> (with thinking preference
                applied).
              </li>
              <li>
                <strong>User message</strong> — <strong>LLM prompt (advanced)</strong> (or the built-in default if
                empty), then the bookmark fields: text, folder, author, links, media description, linked excerpts.
              </li>
              <li>
                The model must return a compact JSON object with{" "}
                <code className="rounded bg-white px-1 py-0.5 text-xs">summary</code>,{" "}
                <code className="rounded bg-white px-1 py-0.5 text-xs">category</code>, and{" "}
                <code className="rounded bg-white px-1 py-0.5 text-xs">tags</code>. Xbook parses the first JSON object
                in the reply.
              </li>
            </ol>
          </div>

          <div className="overflow-hidden rounded-xl border border-outline-variant/40">
            <div className="grid grid-cols-1 gap-0 md:grid-cols-[200px_minmax(0,1fr)]">
              {[
                [
                  "LLM system prompt",
                  "Short output rules (default: return only compact valid JSON, no markdown or prose). Keep this tight so the model stays on JSON. Safe for Gemma, Qwen, Llama, and similar chat models.",
                ],
                [
                  "LLM prompt (advanced)",
                  "The enrichment task template: summary style, category list, tagging, media/transcript rules, English-only JSON values. Leave blank to use the built-in researcher default, or click Reset prompt to default after customizing. Edit only if you want a different voice or taxonomy—not when switching hosts.",
                ],
                [
                  "Enable LLM thinking",
                  "Default off (recommended for batch enrichment). When off, Xbook prepends /no_think for models that honor it (e.g. some Qwen thinking builds)—faster and more of the token budget goes to the JSON body. When on, that line is removed. Turning it on does not enable a special “thinking API” on models like Gemma; leave it off for REMOTE high-concurrency runs.",
                ],
                [
                  "Limit response length",
                  "Caps max tokens for the reply (default around 2000). Fine for compact JSON. Raise it if Processing shows empty responses or “JSON never closed” (often truncated output or long reasoning).",
                ],
                [
                  "Context window (input)",
                  "Caps how much bookmark/transcript text is sent (character budget derived from this setting). REMOTE presets may set a lower value to match the server’s max model length.",
                ],
              ].map(([label, detail]) => (
                <div key={label} className="contents">
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

          <div className="rounded-xl border border-emerald-500/25 bg-emerald-50/60 p-4 space-y-2">
            <p className="text-sm font-bold text-emerald-900">Recommended defaults</p>
            <ul className="list-disc list-inside text-sm text-on-surface-variant leading-6 space-y-1">
              <li>
                <strong>System prompt</strong> — keep the default JSON-only instruction (optional{" "}
                <code className="rounded bg-white px-1 py-0.5 text-xs">/no_think</code> is harmless on models that
                ignore it).
              </li>
              <li>
                <strong>LLM prompt (advanced)</strong> — use the built-in default unless you are intentionally
                redesigning summaries.
              </li>
              <li>
                <strong>Enable LLM thinking</strong> — leave <strong>off</strong> for enrichment speed and
                reliability.
              </li>
              <li>
                <strong>Chat vs embeddings</strong> — if chat is REMOTE/vLLM, keep embedding base URL on a host that
                actually serves <code className="rounded bg-white px-1 py-0.5 text-xs">/v1/embeddings</code> (Ollama
                or LM Studio), with a real embed model such as{" "}
                <code className="rounded bg-white px-1 py-0.5 text-xs">nomic-embed-text</code>.
              </li>
            </ul>
          </div>
        </div>
      </div>
    </DocsPageShell>
  );
}
