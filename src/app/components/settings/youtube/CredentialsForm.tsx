import { SecretField } from "../SharedFields";
import type React from "react";
import type { Settings } from "../types";

type Props = {
  form: Settings;
  updateField: (key: keyof Settings) => (event: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => void;
  ytJsonInputRef: React.RefObject<HTMLInputElement | null>;
  uploadGoogleClientJson: (event: React.ChangeEvent<HTMLInputElement>) => void | Promise<void>;
};

export function CredentialsForm({
  form,
  updateField,
  ytJsonInputRef,
  uploadGoogleClientJson,
}: Props) {
  return (
    <>
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <input ref={ytJsonInputRef} type="file" accept="application/json" onChange={uploadGoogleClientJson} className="hidden" />
        <button type="button" onClick={() => ytJsonInputRef.current?.click()} className="rounded-md border border-black/10 px-4 py-2 text-sm font-semibold text-slate-800 transition">Browse Google OAuth JSON</button>
        <p className="text-xs text-slate-500">Loads credentials from your downloaded file.</p>
      </div>
      <div className="grid gap-4 md:grid-cols-2">
        <div className="space-y-2">
          <label className="text-sm font-semibold">YouTube client ID *</label>
          <input type="text" value={form.ytClientId ?? ""} onChange={updateField("ytClientId")} placeholder="Google OAuth client ID" className="w-full rounded-md border border-black/10 bg-white px-4 py-3 text-sm" />
        </div>
        <SecretField label="YouTube client secret *" value={form.ytClientSecret} onChange={updateField("ytClientSecret")} placeholder="Google OAuth client secret" />
        <div className="space-y-2 md:col-span-2">
          <label className="text-sm font-semibold">YouTube redirect URI *</label>
          <input type="text" value={form.ytRedirectUri ?? ""} onChange={updateField("ytRedirectUri")} placeholder="http://localhost:3000/api/oauth/youtube/callback" className="w-full rounded-md border border-black/10 bg-white px-4 py-3 text-sm" />
        </div>
      </div>
    </>
  );
}
