"use client";

import { useSettingsContext } from "../../hooks/settings/useSettingsContext";
import { useYouTubeSettings } from "../../hooks/settings/useYouTubeSettings";
import { CredentialsForm } from "./youtube/CredentialsForm";
import { ActionButtons } from "./youtube/ActionButtons";
import { DiagnosticsProbe } from "./youtube/DiagnosticsProbe";
import { YouTubeLogo } from "../Icons";
import { SettingsSection } from "./SharedFields";

export function YouTubeSettings() {
  const { form, updateField, saving } = useSettingsContext();
  const yt = useYouTubeSettings();

  return (
    <SettingsSection
      title="YouTube integration"
      description="Connect Google to import playlists and video bookmarks."
      icon={<span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-red-50 text-red-600"><YouTubeLogo className="h-4 w-6" /></span>}
    >
      <div className="flex flex-col gap-4">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <h3 className="text-sm font-semibold">OAuth credentials</h3>
          <p className="text-xs text-slate-500">Status: {form.ytAccessToken ? "Connected" : "Not connected"}</p>
        </div>
        <CredentialsForm form={form} updateField={updateField} {...yt} />
        <ActionButtons saving={saving} {...yt} />
        <DiagnosticsProbe result={yt.ytDiagnosticResult} />
      </div>
    </SettingsSection>
  );
}
