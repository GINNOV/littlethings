export function DiagnosticsPanel({ xDiagnostics, runXDiagnostics, runningXDiagnostics, xDiagnosticResult }: any) {
  const row = (l: string, v: string) => <div className="rounded-md bg-slate-50 p-3"><dt className="text-xs uppercase text-slate-500">{l}</dt><dd className="mt-1 font-semibold">{v}</dd></div>;
  const expiry = xDiagnostics.tokenExpiresAt ? new Date(xDiagnostics.tokenExpiresAt).toLocaleString() : "Unknown";

  return (
    <section className="rounded-lg border border-black/10 bg-white p-6 shadow-sm">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div><h2 className="text-lg font-semibold">Connection diagnostics</h2><p className="text-xs text-slate-500">Live probe against X API.</p></div>
        <button onClick={runXDiagnostics} disabled={runningXDiagnostics} className="rounded-md border border-black/10 px-4 py-2 text-sm font-semibold text-slate-800 transition disabled:opacity-60">{runningXDiagnostics ? "Running…" : "Run diagnostics"}</button>
      </div>
      <dl className="mt-4 grid gap-3 md:grid-cols-2">
        {row("Access token", xDiagnostics.hasAccessToken ? "Present" : "Missing")}
        {row("Refresh token", xDiagnostics.hasRefreshToken ? "Present" : "Missing")}
        {row("Stored user ID", xDiagnostics.userId ?? "Missing")}
        {row("Token expiry", expiry)}
        <div className="rounded-md bg-slate-50 p-3 md:col-span-2"><dt className="text-xs uppercase text-slate-500">Scope</dt><dd className="mt-1 break-all font-semibold">{xDiagnostics.scope ?? "Missing"}</dd></div>
      </dl>
      {xDiagnosticResult && <pre className="mt-4 max-h-96 overflow-auto whitespace-pre-wrap rounded-md bg-slate-950 p-4 text-xs text-slate-100">{JSON.stringify(xDiagnosticResult, null, 2)}</pre>}
    </section>
  );
}
