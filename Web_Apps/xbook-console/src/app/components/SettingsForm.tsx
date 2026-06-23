"use client";

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

export default function SettingsForm(props: Props) {
  return (
    <SettingsProvider initial={props.initial} defaultPrompt={props.defaultPrompt}>
      <SettingsFormBody {...props} />
    </SettingsProvider>
  );
}

function SettingsFormBody({
  usedThisMonth,
  agentApiBaseUrl,
  agentApiTokenConfigured,
  xDiagnostics,
}: Props) {
  const { saving, message, persistSettings, setMessage } = useSettingsContext();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const ok = await persistSettings();
    if (ok) setMessage("Settings saved.");
  };

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-8">
      <XSettings xDiagnostics={xDiagnostics} />
      <YouTubeSettings />
      <LLMSettings />
      <AudioSettings />
      <UsageSettings usedThisMonth={usedThisMonth} />
      <AgentApiSettings baseUrl={agentApiBaseUrl} tokenConfigured={agentApiTokenConfigured} />
      <DatabaseSettings />

      <div className="flex flex-wrap items-center gap-4">
        <button
          type="submit"
          disabled={saving}
          className={primaryButtonClass}
        >
          {saving ? "Saving…" : "Save settings"}
        </button>
        {message ? <p className="text-sm text-slate-600">{message}</p> : null}
      </div>
    </form>
  );
}
