import { primaryButtonClass, secondaryButtonClass, SecretField } from "../SharedFields";
import type React from "react";
import type { Settings } from "../types";

type Props = {
  form: Settings;
  updateField: (key: keyof Settings) => (event: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => void;
  connectOAuth: () => void | Promise<void>;
  clearOAuth: () => void | Promise<void>;
  testX: () => void | Promise<void>;
  testingX: boolean;
  xTest: string | null;
};

export function OauthSection({
  form,
  updateField,
  connectOAuth,
  clearOAuth,
  testX,
  testingX,
  xTest,
}: Props) {
  const input = "w-full rounded-md border border-black/10 bg-white px-4 py-3 text-sm";
  return (
    <section className="rounded-lg border border-black/10 bg-white p-6 shadow-sm">
      <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
        <div><h2 className="text-lg font-semibold">OAuth settings</h2><p className="text-xs text-slate-500">Required for bookmark sync.</p></div>
        <p className="text-xs text-slate-500">Status: {form.xAccessToken ? "Connected" : "Not connected"}</p>
      </div>
      <div className="grid gap-4 md:grid-cols-2">
        <div className="space-y-2"><label className="text-sm font-semibold">X client ID *</label><input type="text" value={form.xClientId ?? ""} onChange={updateField("xClientId")} placeholder="Client ID" className={input} /></div>
        <SecretField label="X client secret" value={form.xClientSecret} onChange={updateField("xClientSecret")} placeholder="Client secret" />
        <SecretField label="Access token" value={form.xAccessToken} onChange={updateField("xAccessToken")} placeholder="OAuth access token" />
        <SecretField label="Refresh token" value={form.xRefreshToken} onChange={updateField("xRefreshToken")} placeholder="OAuth refresh token" />
        <div className="space-y-2 md:col-span-2"><label className="text-sm font-semibold">OAuth redirect URI *</label><input type="text" value={form.xRedirectUri ?? ""} onChange={updateField("xRedirectUri")} placeholder="callback url" className={input} /></div>
      </div>
      <div className="mt-4 flex flex-wrap items-center gap-3">
        <button onClick={connectOAuth} className={primaryButtonClass}>Save & Connect</button>
        <button onClick={clearOAuth} className={secondaryButtonClass}>Disconnect</button>
        <button onClick={testX} disabled={testingX} className={secondaryButtonClass}>{testingX ? "Testing…" : "Test connection"}</button>
        {xTest && <p className="text-sm text-slate-600">{xTest}</p>}
      </div>
    </section>
  );
}
