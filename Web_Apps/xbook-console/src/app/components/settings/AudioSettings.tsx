"use client";

import { playSuccessSound, playErrorSound } from "@/lib/audio";
import { useAudioSettings } from "../../hooks/settings/useAudioSettings";
import { SettingsSection, secondaryButtonClass } from "./SharedFields";

export function AudioSettings() {
  const { form, updateBooleanField } = useAudioSettings();

  return (
    <SettingsSection
      title="Audio configuration"
      description="Choose audio notifications for long-running enrichment batches."
    >
      <div className="grid gap-4 md:grid-cols-2">
        <div className="flex flex-col gap-3 rounded-md border border-black/10 bg-white px-4 py-3 text-sm">
          <label className="flex items-start gap-3 cursor-pointer">
            <input
              type="checkbox"
              checked={form.soundOnComplete ?? false}
              onChange={updateBooleanField("soundOnComplete")}
              className="mt-1 h-4 w-4"
            />
            <span>
              <span className="block font-semibold tracking-tight">Grab attention when batch enrichment is completed</span>
              <span className="block text-xs text-slate-500">Plays a synth coin sound when a batch finishes successfully.</span>
            </span>
          </label>
          <button
            type="button"
            onClick={playSuccessSound}
            className={`w-fit ${secondaryButtonClass}`}
          >
            Preview sound
          </button>
        </div>

        <div className="flex flex-col gap-3 rounded-md border border-black/10 bg-white px-4 py-3 text-sm">
          <label className="flex items-start gap-3 cursor-pointer">
            <input
              type="checkbox"
              checked={form.soundOnError ?? false}
              onChange={updateBooleanField("soundOnError")}
              className="mt-1 h-4 w-4"
            />
            <span>
              <span className="block font-semibold tracking-tight">Sad sound when a failure occurs</span>
              <span className="block text-xs text-slate-500">Plays a low slide tone if an item fails to process.</span>
            </span>
          </label>
          <button
            type="button"
            onClick={playErrorSound}
            className={`w-fit ${secondaryButtonClass} hover:bg-red-50 hover:text-red-700`}
          >
            Preview sound
          </button>
        </div>
      </div>
    </SettingsSection>
  );
}
