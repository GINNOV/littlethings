export function DiagnosticsProbe({ result }: { result: any }) {
  if (!result) return null;
  const s = result.summary;
  const badge = (ok: boolean) => `rounded px-1.5 py-0.5 font-bold uppercase ${ok ? "bg-emerald-100 text-emerald-700" : "bg-red-100 text-red-700"}`;
  const row = (label: string, ok: boolean) => (
    <div className="flex justify-between border-b border-slate-100 pb-1">
      <span className="text-slate-400">{label}:</span>
      <span className={ok ? "text-emerald-600" : "text-red-600"}>{ok ? "Stored/Found" : "Missing"}</span>
    </div>
  );

  return (
    <div className="mt-6 space-y-4 rounded-lg bg-slate-50 p-4 font-mono text-[11px]">
      <div className="flex items-center justify-between border-b border-slate-200 pb-2">
        <span className="font-bold uppercase text-slate-500">YouTube Connectivity Probe</span>
        <span className={badge(result.ok)}>{result.ok ? "Passed" : "Failed"}</span>
      </div>
      <div className="grid grid-cols-2 gap-x-4 gap-y-2">
        {row("Access Token", !!s?.hasAccessToken)}
        {row("Refresh Token", !!s?.hasRefreshToken)}
        {row("Client ID", !!s?.hasClientId)}
        {row("Client Secret", !!s?.hasClientSecret)}
      </div>
      <div className="space-y-1">
        <p className="text-slate-400">Probe Result:</p>
        {result.probe ? (
          <div className="rounded border border-slate-200 bg-white p-2 text-slate-700">
            <p className="mb-1 border-b border-slate-50 pb-1 font-bold">Status: {result.probe.status}</p>
            <pre className="max-h-32 overflow-auto whitespace-pre-wrap">{JSON.stringify(result.probe.body, null, 2)}</pre>
          </div>
        ) : <p className="italic text-red-600">{result.error || "Probe failed."}</p>}
      </div>
    </div>
  );
}
