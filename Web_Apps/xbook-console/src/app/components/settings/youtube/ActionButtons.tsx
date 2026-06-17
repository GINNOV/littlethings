"use client";

import { useState } from "react";
import { primaryButtonClass, secondaryButtonClass } from "../SharedFields";

type Props = {
  saving: boolean;
  connectYouTubeOAuth: () => void | Promise<void>;
  clearYouTubeOAuth: () => void | Promise<void>;
  testYt: () => void | Promise<void>;
  testingYt: boolean;
  ytTest: string | null;
  runYtDiagnostics: () => void | Promise<void>;
  runningYtDiagnostics: boolean;
  getYouTubeAuthUrl: () => Promise<string | null>;
  generatingYtUrl: boolean;
};

export function ActionButtons({
  saving,
  connectYouTubeOAuth,
  clearYouTubeOAuth,
  testYt,
  testingYt,
  ytTest,
  runYtDiagnostics,
  runningYtDiagnostics,
  getYouTubeAuthUrl,
  generatingYtUrl,
}: Props) {
  const [copied, setCopied] = useState(false);
  
  const copyUrl = async () => {
    const url = await getYouTubeAuthUrl();
    if (url) {
      await navigator.clipboard.writeText(url);
      setCopied(true);
      setTimeout(() => setCopied(false), 3000);
    }
  };

  return (
    <div className="mt-4 flex flex-wrap items-center gap-3">
      <button type="button" onClick={connectYouTubeOAuth} className={primaryButtonClass}>{saving ? "Saving…" : "Save & Connect YouTube"}</button>
      <button type="button" onClick={clearYouTubeOAuth} className={secondaryButtonClass}>Disconnect</button>
      <button type="button" onClick={testYt} disabled={testingYt} className={secondaryButtonClass}>{testingYt ? "Testing…" : "Test connection"}</button>
      <button type="button" onClick={runYtDiagnostics} disabled={runningYtDiagnostics} className={secondaryButtonClass}>{runningYtDiagnostics ? "Running…" : "Run diagnostics"}</button>
      <button type="button" onClick={copyUrl} disabled={generatingYtUrl} className={`${secondaryButtonClass} ${copied ? "border-emerald-200 bg-emerald-50 text-emerald-700" : "text-emerald-800"}`}>
        {generatingYtUrl ? "Generating…" : copied ? "Copied link" : "Copy OAuth URL"}
      </button>
      {ytTest && <p className="text-sm text-slate-600">{ytTest}</p>}
    </div>
  );
}
