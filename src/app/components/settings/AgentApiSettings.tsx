"use client";

import { useMemo, useState } from "react";
import { HelpTooltip, SettingsSection } from "./SharedFields";

type Props = {
  baseUrl: string;
  tokenConfigured: boolean;
};

const readEndpoints = [
  {
    method: "GET",
    path: "/api/agent",
    purpose: "Endpoint index and examples",
  },
  {
    method: "GET",
    path: "/api/agent?resource=bookmarks&pageSize=50",
    purpose: "List or filter bookmarks",
  },
  {
    method: "GET",
    path: "/api/agent?resource=bookmark&id=<bookmarkId>",
    purpose: "Retrieve one bookmark",
  },
  {
    method: "GET",
    path: "/api/agent?resource=folders",
    purpose: "List bookmark folders",
  },
  {
    method: "GET",
    path: "/api/agent?resource=runs&take=50",
    purpose: "Inspect processing runs",
  },
];

const writeActions = [
  {
    action: "upsertBookmark",
    purpose: "Create or replace local bookmark data",
  },
  {
    action: "updateBookmark",
    purpose: "Update selected bookmark fields",
  },
  {
    action: "appendBookmarkData",
    purpose: "Append summary, tags, or media notes",
  },
  {
    action: "upsertFolder",
    purpose: "Create or rename a folder",
  },
];

function CopyButton({ text, label = "Copy" }: { text: string; label?: string }) {
  const [status, setStatus] = useState<"idle" | "copied" | "failed">("idle");

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(text);
      setStatus("copied");
    } catch {
      setStatus("failed");
    }
    window.setTimeout(() => setStatus("idle"), 4000);
  };

  return (
    <span className="flex items-center gap-2">
      <button
        type="button"
        onClick={handleCopy}
        className="rounded-md border border-black/10 px-3 py-1.5 text-[10px] font-bold uppercase text-slate-700 transition hover:bg-slate-50"
      >
        {label}
      </button>
      <span aria-live="polite" className="min-w-10 text-[10px] font-bold uppercase text-slate-500">
        {status === "copied" ? "Copied" : status === "failed" ? "Failed" : ""}
      </span>
    </span>
  );
}

export function AgentApiSettings({ baseUrl, tokenConfigured }: Props) {
  const bookmarkSearchUrl = `${baseUrl}?resource=bookmarks&pageSize=25&q=ai`;
  const sampleRead = `curl -sS '${bookmarkSearchUrl}'`;
  const sampleWrite = useMemo(() => {
    const authHeader = tokenConfigured ? " -H 'Authorization: Bearer $AGENT_API_TOKEN'" : "";
    return [
      `curl -sS -X POST '${baseUrl}'${authHeader} \\`,
      "  -H 'content-type: application/json' \\",
      "  --data '{\"action\":\"appendBookmarkData\",\"bookmarkId\":\"<bookmarkId>\",\"data\":{\"tags\":[\"reviewed\"],\"summary\":\"Agent note.\"}}'",
    ].join("\n");
  }, [baseUrl, tokenConfigured]);

  return (
    <SettingsSection
      title="Agent API endpoints"
      description="Use local HTTP routes from agents, shell scripts, or MCP-style tools."
    >
      <div className="flex flex-wrap items-center justify-between gap-3">
        <p className="text-sm text-slate-600">
          Local HTTP API for scripts and agents to retrieve, update, and append backend data.
          <HelpTooltip text="Read endpoints are local-only by default. Write actions require a token when AGENT_API_TOKEN is configured." />
        </p>
        <span className={`rounded-full px-3 py-1 text-[10px] font-bold uppercase ${tokenConfigured ? "bg-emerald-50 text-emerald-700" : "bg-amber-50 text-amber-700"}`}>
          {tokenConfigured ? "Token required" : "Localhost only"}
        </span>
      </div>

      <div className="mt-4 grid gap-4">
        <div className="min-w-0 overflow-hidden rounded-md border border-black/10">
          <div className="hidden bg-slate-50 px-3 py-2 text-[10px] font-bold uppercase text-slate-500 md:grid md:grid-cols-[72px_minmax(0,1fr)_220px]">
            <span>Method</span>
            <span>Endpoint</span>
            <span>Purpose</span>
          </div>
          {readEndpoints.map((endpoint) => (
            <div key={endpoint.path} className="grid min-w-0 gap-2 border-t border-black/10 px-3 py-3 text-sm md:grid-cols-[72px_minmax(0,1fr)_220px]">
              <span className="font-mono text-xs font-bold text-emerald-700">{endpoint.method}</span>
              <code className="block min-w-0 overflow-x-auto whitespace-nowrap rounded bg-slate-50 px-2 py-1 text-xs text-slate-800">{endpoint.path}</code>
              <span className="text-xs text-slate-500 md:text-sm">{endpoint.purpose}</span>
            </div>
          ))}
        </div>

        <div className="min-w-0 rounded-md border border-black/10 bg-slate-50 p-4">
          <div className="flex items-center justify-between gap-3">
            <p className="text-xs font-bold uppercase text-slate-500">Base URL</p>
            <CopyButton text={baseUrl} />
          </div>
          <code className="mt-2 block min-w-0 break-all rounded border border-black/10 bg-white px-3 py-2 text-xs text-slate-800">{baseUrl}</code>
          <p className="mt-3 text-xs leading-5 text-slate-600">
            {tokenConfigured
              ? "Send Authorization: Bearer $AGENT_API_TOKEN or x-agent-token with every request."
              : "Requests are accepted from localhost. Set AGENT_API_TOKEN in the environment to require a token."}
          </p>
        </div>
      </div>

      <div className="mt-4 grid gap-4 md:grid-cols-2">
        <div className="min-w-0 rounded-md border border-black/10 p-4">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <h3 className="text-sm font-semibold">Write actions</h3>
            <CopyButton text={sampleWrite} label="Copy example" />
          </div>
          <div className="mt-3 space-y-2">
            {writeActions.map((item) => (
              <div
                key={item.action}
                className="grid gap-1 text-sm sm:grid-cols-[minmax(0,1fr)_minmax(0,1.2fr)] sm:gap-3"
              >
                <code className="rounded bg-slate-50 px-2 py-1 text-xs text-slate-800">{item.action}</code>
                <span className="text-xs leading-5 text-slate-500 sm:text-right">{item.purpose}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="min-w-0 rounded-md border border-black/10 p-4">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <h3 className="text-sm font-semibold">Read example</h3>
            <CopyButton text={sampleRead} label="Copy curl" />
          </div>
          <pre className="mt-3 max-h-36 max-w-full overflow-auto rounded-md bg-slate-950 p-3 text-xs leading-5 text-slate-100">
            {sampleRead}
          </pre>
        </div>
      </div>
    </SettingsSection>
  );
}
