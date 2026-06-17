import { XLogo, YouTubeLogo } from "../Icons";

export function AccountStats({ tab, used, cap, bal, live, cost, sum, pend, total }: any) {
  const lbl = tab === "x" && bal !== null ? "Prepaid Balance" : "Monthly API Usage";
  const unit = tab === "x" && bal !== null ? "USD" : (tab === "yt" ? "Imports" : "Tweets");
  const val = tab === "x" && bal !== null ? `$${bal}` : used;
  const note = tab === "yt" ? `Using ${used} of ${cap} monthly limit.` : (bal !== null ? "Total prepaid balance remaining." : `Using ${used} of ${cap} monthly limit. ${Math.max(0, cap - used)} remaining.`);

  return (
    <div className="rounded-lg bg-surface-container-lowest p-5 shadow-sm border border-outline-variant/30">
      <div className="flex items-start justify-between">
        <h2 className="flex items-center gap-2 text-base font-semibold">{tab === "yt" ? <YouTubeLogo className="h-4 w-6" /> : <XLogo className="h-5 w-5" />}</h2>
        {live && tab === "x" && <span className="rounded-full bg-emerald-100 px-2 py-0.5 text-[10px] font-bold uppercase text-emerald-800">Live</span>}
      </div>
      <div className="mt-5">
        <p className="text-[10px] font-bold uppercase tracking-wider text-on-surface-variant/70">{lbl}</p>
        <div className="mt-1 flex items-baseline gap-2"><p className="font-headline text-4xl">{val}</p><p className="text-xs font-semibold uppercase text-on-surface-variant">{unit}</p></div>
        <p className="mt-1 text-sm text-on-surface-variant leading-tight">{note}</p>
        {tab === "x" && cost !== null && <p className="mt-1 text-[10px] font-bold uppercase text-on-surface-variant/60">Cost per call: ${cost}</p>}
        {tab === "x" && (
          <a 
            href="https://console.x.com/accounts/1527020579089309696" 
            target="_blank" 
            rel="noreferrer"
            className="mt-2 inline-block text-[10px] font-bold uppercase text-primary hover:underline"
          >
            X Developer Console ↗
          </a>
        )}
        {bal === null && <div className="mt-4 h-1.5 overflow-hidden rounded-md bg-surface-container-high"><div className="h-full bg-primary" style={{ width: `${Math.min(100, (used / cap) * 100)}%` }} /></div>}
      </div>
      <div className="mt-6 border-t border-outline-ghost pt-4">
        <p className="text-[10px] font-bold uppercase tracking-wider text-on-surface-variant/70">Local Library</p>
        <div className="mt-3 grid grid-cols-2 gap-3 text-sm">
          <div><p className="text-xs uppercase text-on-surface-variant">Summarized</p><p className="font-semibold">{sum}</p></div>
          <div><p className="text-xs uppercase text-on-surface-variant">Pending</p><p className="font-semibold text-secondary">{pend}</p></div>
        </div>
        <p className="mt-3 text-[11px] font-medium text-on-surface-variant/60">Total stored locally: <span className="font-bold text-on-surface">{total}</span> {tab === "yt" ? "videos" : "tweets"}</p>
      </div>
    </div>
  );
}
