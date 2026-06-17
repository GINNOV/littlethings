"use client";

import { useSettingsContext } from "./useSettingsContext";

export function useAudioSettings() {
  const { form, updateBooleanField } = useSettingsContext();
  
  return {
    form,
    updateBooleanField,
  };
}
