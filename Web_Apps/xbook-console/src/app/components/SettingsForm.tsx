"use client";

import { useMemo, useState } from "react";
import { SettingsProvider, useSettingsContext } from "../hooks/settings/useSettingsContext";
import { XSettings } from "./settings/XSettings";
import { YouTubeSettings } from "./settings/YouTubeSettings";
import { LLMSettings } from "./settings/LLMSettings";
import { AudioSettings } from "./settings/AudioSettings";
import { UsageSettings } from "./settings/UsageSettings";
import { AgentApiSettings } from "./settings/AgentApiSettings";
import { DatabaseSettings } from "./settings/DatabaseSettings";
import { primaryButtonClass } from "./settings/SharedFields";
import { Settings } from "./settings/types";

type Props = {
  initial: Settings;
  usedThisMonth: number;
  defaultPrompt: string;
  agentApiBaseUrl: string;
  agentApiTokenConfigured: boolean;
  xDiagnostics: {
    hasAccessToken: boolean;
    hasRefreshToken: boolean;
    hasBearerToken: boolean;
    userId: string | null;
    tokenExpiresAt: string | null;
    scope: string | null;
    apiBase: string;
  };
};

type TabId = "connections" | "ai" | "limits" | "data" | "agents";

const TABS: { id: TabId; label: string; description: string }[] = [
  { id: "connections", label: "Connections", description: "X and YouTube accounts" },
  { id: "ai", label: "AI", description: "Models, prompts, and tests" },
  { id: "limits", label: "Limits", description: "Caps, batches, and sounds" },
  { id: "data", label: "Data", description: "Backup and restore" },
  { id: "agents", label: "Agents", description: "Agent API access" },
];

export default function SettingsForm(props: Props) {
  return (
    <SettingsProvider initial={props.initial} defaultPrompt={props.defaultPrompt}>
      <SettingsFormBody {...props} />
    </SettingsProvider>
  );
}

function StatusChip({
  ok,
  label,
}: {
  ok: boolean;
  label: string;
}) {
  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-[11px] font-semibold ${
        ok
          ? "border-emerald-200 bg-emerald-50 text-emerald-800"
          : "border-amber-200 bg-amber-50 text-amber-800"
      }`}
    >
      <span className={`h-1.5 w-1.5 rounded-full ${ok ? "bg-emerald-500" : "bg-amber-500"}`} />
      {label}
    </span>
  );
}

function SettingsFormBody({
  usedThisMonth,
  agentApiBaseUrl,
  agentApiTokenConfigured,
  xDiagnostics,
}: Props) {
  const { form, saving, message, persistSettings, setMessage, isDirty } = useSettingsContext();
  const [activeTab, setActiveTab] = useState<TabId>("connections");

  const setup = useMemo(() => {
    const xConnected = Boolean(xDiagnostics.hasAccessToken || form.xAccessToken);
    const chatModelSet = Boolean(form.llmModel?.trim());
    const embeddingModelSet = Boolean(form.llmEmbeddingModel?.trim());
    return { xConnected, chatModelSet, embeddingModelSet };
  }, [xDiagnostics.hasAccessToken, form.xAccessToken, form.llmModel, form.llmEmbeddingModel]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const ok = await persistSettings();
    if (ok) setMessage("Settings saved.");
  };

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-6">
      <div className="flex flex-wrap items-center gap-2">
        <span className="mr-1 text-xs font-semibold uppercase tracking-wide text-slate-500">
          Setup status
        </span>
        <StatusChip ok={setup.xConnected} label={setup.xConnected ? "X connected" : "X not connected"} />
        <StatusChip
          ok={setup.chatModelSet}
          label={setup.chatModelSet ? "Chat model set" : "Chat model missing"}
        />
        <StatusChip
          ok={setup.embeddingModelSet}
          label={setup.embeddingModelSet ? "Embedding model set" : "Embedding model missing"}
        />
      </div>

      <div
        role="tablist"
        aria-label="Settings sections"
        className="flex flex-wrap gap-2 border-b border-black/10 pb-3"
      >
        {TABS.map((tab) => {
          const selected = activeTab === tab.id;
          return (
            <button
              key={tab.id}
              type="button"
              role="tab"
              aria-selected={selected}
              id={`settings-tab-${tab.id}`}
              onClick={() => setActiveTab(tab.id)}
              className={`rounded-md px-3 py-2 text-left transition ${
                selected
                  ? "bg-emerald-700 text-white shadow-sm"
                  : "border border-black/10 bg-white text-slate-700 hover:bg-slate-50"
              }`}
            >
              <span className="block text-sm font-semibold">{tab.label}</span>
              <span className={`block text-[11px] ${selected ? "text-emerald-100" : "text-slate-500"}`}>
                {tab.description}
              </span>
            </button>
          );
        })}
      </div>

      <div
        role="tabpanel"
        aria-labelledby={`settings-tab-${activeTab}`}
        className="flex flex-col gap-6"
      >
        {activeTab === "connections" ? (
          <>
            <XSettings xDiagnostics={xDiagnostics} />
            <YouTubeSettings />
          </>
        ) : null}

        {activeTab === "ai" ? <LLMSettings /> : null}

        {activeTab === "limits" ? (
          <>
            <UsageSettings usedThisMonth={usedThisMonth} />
            <AudioSettings />
          </>
        ) : null}

        {activeTab === "data" ? <DatabaseSettings /> : null}

        {activeTab === "agents" ? (
          <AgentApiSettings baseUrl={agentApiBaseUrl} tokenConfigured={agentApiTokenConfigured} />
        ) : null}
      </div>

      <div className="flex flex-wrap items-center gap-4 border-t border-black/10 pt-4">
        <button type="submit" disabled={saving} className={primaryButtonClass}>
          {saving ? "Saving…" : "Save settings"}
        </button>
        {isDirty ? (
          <span className="flex items-center gap-1.5 rounded-full border border-amber-100 bg-amber-50 px-3 py-1 text-[10px] font-bold uppercase tracking-tight text-amber-700">
            <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-amber-500" />
            Unsaved changes
          </span>
        ) : null}
        {message ? <p className="text-sm text-slate-600">{message}</p> : null}
      </div>
    </form>
  );
}
