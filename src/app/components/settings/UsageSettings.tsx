"use client";

import { useUsageSettings } from "../../hooks/settings/useUsageSettings";
import { useSettingsContext } from "../../hooks/settings/useSettingsContext";
import { HelpTooltip, SettingsSection, secondaryButtonClass } from "./SharedFields";

type Props = {
  usedThisMonth: number;
};

export function UsageSettings({ usedThisMonth }: Props) {
  const { form, updateNumberField } = useSettingsContext();
  const {
    markingLatest,
    resettingBaseline,
    syncingEmbeddings,
    markLatest,
    resetBaseline,
    syncEmbeddings,
  } = useUsageSettings();

  return (
    <SettingsSection
      title="Usage limits"
      description="Cap monthly imports to avoid API bans or unexpected costs."
      defaultOpen
    >
      <div className="grid gap-4 md:grid-cols-3">
        <div className="space-y-2">
          <label className="text-sm font-semibold">
            X monthly cap * <HelpTooltip text="Maximum number of bookmarks to fetch from X per month." />
          </label>
          <input
            type="number"
            min={1}
            max={10000}
            value={form.monthlyCap ?? ""}
            onChange={updateNumberField("monthlyCap")}
            className="w-full rounded-md border border-black/10 bg-white px-4 py-3 text-sm"
          />
          <p className="text-[10px] font-bold uppercase text-slate-400 tracking-tight">{usedThisMonth} used this month</p>
        </div>
        <div className="space-y-2">
          <label className="text-sm font-semibold">
            YouTube monthly cap * <HelpTooltip text="Maximum number of video entries to fetch from YouTube per month." />
          </label>
          <input
            type="number"
            min={1}
            max={10000}
            value={form.ytMonthlyCap ?? ""}
            onChange={updateNumberField("ytMonthlyCap")}
            className="w-full rounded-md border border-black/10 bg-white px-4 py-3 text-sm"
          />
          <p className="text-[10px] font-bold uppercase text-slate-400 tracking-tight">Sync stops when quota is reached</p>
        </div>
        <div className="space-y-2">
          <label className="text-sm font-semibold">
            Enrichment batch size * <HelpTooltip text="Number of bookmarks to process per LLM request. Larger batches are faster but more prone to timeouts." />
          </label>
          <input
            type="number"
            min={1}
            max={200}
            value={form.enrichBatchSize ?? ""}
            onChange={updateNumberField("enrichBatchSize")}
            className="w-full rounded-md border border-black/10 bg-white px-4 py-3 text-sm"
          />
          <p className="text-[10px] font-bold uppercase text-slate-400 tracking-tight">System default is 50 per run</p>
        </div>
      </div>
      <div className="mt-4 flex flex-wrap items-center gap-3">
        <button
          type="button"
          onClick={markLatest}
          disabled={markingLatest}
          className={secondaryButtonClass}
        >
          {markingLatest ? "Marking…" : "Mark latest X bookmark as baseline"}
        </button>
        <button
          type="button"
          onClick={resetBaseline}
          disabled={resettingBaseline}
          className={`${secondaryButtonClass} text-error hover:bg-red-50`}
        >
          {resettingBaseline ? "Resetting…" : "Reset X sync baseline"}
        </button>
        <button
          type="button"
          onClick={syncEmbeddings}
          disabled={syncingEmbeddings}
          className={secondaryButtonClass}
        >
          {syncingEmbeddings ? "Syncing…" : "Sync all missing embeddings"}
        </button>
      </div>
    </SettingsSection>
  );
}
