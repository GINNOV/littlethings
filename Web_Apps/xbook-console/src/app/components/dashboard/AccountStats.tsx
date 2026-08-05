import { XLogo, YouTubeLogo } from "../Icons";

type Props = {
  tab: "x" | "yt";
  used: number;
  cap: number;
  bal: string | null;
  live: boolean;
  cost: number | null;
  sum: number;
  pend: number;
  total: number;
  /** "live" = X API usage; "local" = this app's import counter against your configured cap */
  usageSource?: "live" | "local";
};

export function AccountStats({
  tab,
  used,
  cap,
  bal,
  live,
  cost,
  sum,
  pend,
  total,
  usageSource = "local",
}: Props) {
  const isPrepaid = tab === "x" && bal !== null;
  const isLiveApi = tab === "x" && live && usageSource === "live";
  const safeCap = cap > 0 ? cap : 1;
  const remaining = Math.max(0, (cap || 0) - used);
  const progress = bal === null ? Math.min(100, (used / safeCap) * 100) : 0;

  // Be honest: local counter tracks imports we created, not X platform API spend
  const lbl = isPrepaid
    ? "Prepaid Balance"
    : isLiveApi
      ? "Monthly API Usage"
      : "Monthly Imports";
  const unit = isPrepaid ? "USD" : tab === "yt" ? "Imports" : isLiveApi ? "Tweets" : "Imported";
  const val = isPrepaid ? `$${bal}` : used.toLocaleString();
  const note = isPrepaid
    ? "Total prepaid balance remaining."
    : isLiveApi
      ? `Using ${used.toLocaleString()} of ${cap.toLocaleString()} monthly API limit. ${remaining.toLocaleString()} remaining.`
      : `Imported ${used.toLocaleString()} of ${cap.toLocaleString()} monthly cap. ${remaining.toLocaleString()} remaining.`;

  return (
    <div className="rounded-lg bg-surface-container-lowest p-5 shadow-sm border border-outline-variant/30">
      <div className="flex items-start justify-between">
        <h2 className="flex items-center gap-2 text-base font-semibold">
          {tab === "yt" ? <YouTubeLogo className="h-4 w-6" /> : <XLogo className="h-5 w-5" />}
        </h2>
        {isLiveApi && (
          <span className="rounded-full bg-emerald-100 px-2 py-0.5 text-[10px] font-bold uppercase text-emerald-800">
            Live
          </span>
        )}
        {!isLiveApi && !isPrepaid && tab === "x" && (
          <span className="rounded-full bg-surface-container-high px-2 py-0.5 text-[10px] font-bold uppercase text-on-surface-variant">
            Local cap
          </span>
        )}
      </div>
      <div className="mt-5">
        <p className="text-[10px] font-bold uppercase tracking-wider text-on-surface-variant/70">{lbl}</p>
        <div className="mt-1 flex items-baseline gap-2">
          <p className="font-headline text-4xl">{val}</p>
          <p className="text-xs font-semibold uppercase text-on-surface-variant">{unit}</p>
        </div>
        <p className="mt-1 text-sm text-on-surface-variant leading-tight">{note}</p>
        {tab === "x" && cost !== null && (
          <p className="mt-1 text-[10px] font-bold uppercase text-on-surface-variant/60">
            Cost per call: ${cost}
          </p>
        )}
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
        {bal === null && (
          <div className="mt-4 h-1.5 overflow-hidden rounded-md bg-surface-container-high">
            <div className="h-full bg-primary" style={{ width: `${progress}%` }} />
          </div>
        )}
      </div>
      <div className="mt-6 border-t border-outline-ghost pt-4">
        <p className="text-[10px] font-bold uppercase tracking-wider text-on-surface-variant/70">
          Local Library
        </p>
        <div className="mt-3 grid grid-cols-2 gap-3 text-sm">
          <div>
            <p className="text-xs uppercase text-on-surface-variant">Summarized</p>
            <p className="font-semibold tabular-nums">{sum.toLocaleString()}</p>
          </div>
          <div>
            <p className="text-xs uppercase text-on-surface-variant">Pending</p>
            <p className={`font-semibold tabular-nums ${pend > 0 ? "text-secondary" : ""}`}>
              {pend.toLocaleString()}
            </p>
          </div>
        </div>
        <p className="mt-3 text-[11px] font-medium text-on-surface-variant/60">
          Total stored locally:{" "}
          <span className="font-bold text-on-surface tabular-nums">{total.toLocaleString()}</span>{" "}
          {tab === "yt" ? "videos" : "tweets"}
          {sum + pend === total ? null : (
            <span className="block mt-0.5 text-error/80">
              Counts out of sync (summarized + pending ≠ total)
            </span>
          )}
        </p>
      </div>
    </div>
  );
}
