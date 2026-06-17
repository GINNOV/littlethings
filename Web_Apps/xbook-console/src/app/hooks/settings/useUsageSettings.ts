"use client";

import { useState } from "react";
import { useSettingsContext } from "./useSettingsContext";

export function useUsageSettings() {
  const { setMessage } = useSettingsContext();
  
  const [markingLatest, setMarkingLatest] = useState(false);
  const [resettingBaseline, setResettingBaseline] = useState(false);
  const [syncingEmbeddings, setSyncingEmbeddings] = useState(false);

  const markLatest = async () => {
    setMarkingLatest(true);
    setMessage(null);
    try {
      const res = await fetch("/api/settings/mark-latest", { method: "POST" });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Mark latest failed");
      setMessage("Marked latest X bookmark as the sync baseline.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Mark latest failed");
    } finally {
      setMarkingLatest(false);
    }
  };

  const resetBaseline = async () => {
    setResettingBaseline(true);
    setMessage(null);
    try {
      const res = await fetch("/api/settings/reset-baseline", { method: "POST" });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Reset failed");
      setMessage("Sync baseline reset. Next sync will fetch everything.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Reset failed");
    } finally {
      setResettingBaseline(false);
    }
  };

  const syncEmbeddings = async () => {
    setSyncingEmbeddings(true);
    setMessage(null);
    try {
      const res = await fetch("/api/bookmarks/embeddings/sync", { method: "POST" });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "Sync failed");
      setMessage(`Started embedding sync. Processed: ${json.updated}, Failed: ${json.failed}`);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Sync failed");
    } finally {
      setSyncingEmbeddings(false);
    }
  };

  return {
    markingLatest,
    resettingBaseline,
    syncingEmbeddings,
    markLatest,
    resetBaseline,
    syncEmbeddings,
  };
}
