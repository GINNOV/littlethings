"use client";

import { useSettingsContext } from "../../hooks/settings/useSettingsContext";
import { useXSettings } from "../../hooks/settings/useXSettings";
import { OauthSection } from "./x/OauthSection";
import { DiagnosticsPanel } from "./x/DiagnosticsPanel";
import { AccountDetails } from "./x/AccountDetails";
import { XLogo } from "../Icons";
import { SettingsSection } from "./SharedFields";

type Props = {
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

export function XSettings({ xDiagnostics }: Props) {
  const { form, updateField } = useSettingsContext();
  const x = useXSettings();

  return (
    <SettingsSection
      title="X integration"
      description="Connect X to sync bookmarks and verify account access."
      icon={<span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-black text-white"><XLogo className="h-4 w-4" /></span>}
    >
      <div className="flex flex-col gap-4">
        <OauthSection form={form} updateField={updateField} {...x} />
        <DiagnosticsPanel xDiagnostics={xDiagnostics} {...x} />
        <AccountDetails form={form} updateField={updateField} {...x} />
      </div>
    </SettingsSection>
  );
}
