import { SecretField } from "../SharedFields";
import type React from "react";
import type { Settings } from "../types";

type Props = {
  form: Settings;
  updateField: (key: keyof Settings) => (event: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => void;
  lookupUsername: string;
  setLookupUsername: React.Dispatch<React.SetStateAction<string>>;
  lookupUserId: () => void | Promise<void>;
  lookingUp: boolean;
  lookupMessage: string | null;
};

export function AccountDetails({
  form,
  updateField,
  lookupUsername,
  setLookupUsername,
  lookupUserId,
  lookingUp,
  lookupMessage,
}: Props) {
  const input = "w-full rounded-md border border-black/10 px-4 py-3 text-sm";
  const locked = Boolean(form.xAccessToken);

  return (
    <>
      <section className="rounded-lg border border-black/10 bg-white p-6 shadow-sm">
        <h2 className="text-lg font-semibold">Account details</h2>
        <div className="mt-4 grid gap-4 md:grid-cols-2">
          <div className="space-y-2"><label className="text-sm font-semibold">X user ID *</label><input type="text" value={form.xUserId ?? ""} onChange={updateField("xUserId")} disabled={locked} className={`${input} ${locked ? "bg-slate-100" : ""}`} /></div>
          <div className="space-y-2"><label className="text-sm font-semibold">API base</label><input type="text" value={form.xApiBase ?? ""} onChange={updateField("xApiBase")} className={input} /></div>
        </div>
        <div className="mt-4 flex flex-wrap items-center gap-3">
          <input type="text" value={lookupUsername} onChange={(e) => setLookupUsername(e.target.value)} placeholder="Lookup by @username" className="min-w-[240px] flex-1 rounded-md border border-black/10 px-4 py-2 text-sm" />
          <button onClick={lookupUserId} disabled={lookingUp || !lookupUsername.trim()} className="rounded-md border border-black/10 px-4 py-2 text-sm font-semibold text-slate-800 transition disabled:opacity-60">{lookingUp ? "Searching…" : "Find ID"}</button>
        </div>
        {lookupMessage && <p className="mt-2 text-sm text-slate-600">{lookupMessage}</p>}
      </section>
      <section className="rounded-lg border border-black/10 bg-white p-6 shadow-sm">
        <h2 className="text-lg font-semibold">Legacy bearer token</h2>
        <p className="text-xs text-slate-500">Optional fallback token for older X API workflows.</p>
        <div className="mt-4">
          <SecretField label="Bearer token" value={form.xBearerToken} onChange={updateField("xBearerToken")} />
        </div>
      </section>
    </>
  );
}
