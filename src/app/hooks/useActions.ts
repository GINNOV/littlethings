"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { playSuccessSound, playErrorSound } from "@/lib/audio";

const TOAST_KEY = "xbook:actions-toast";

export function useActions(source: "x" | "yt", enrichBatchSize: number, soundOnComplete?: boolean, soundOnError?: boolean) {
  const router = useRouter();
  const [loading, setLoading] = useState({ x: false, yt: false, enrichX: false, enrichYt: false });
  const [message, setMessage] = useState<string | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);

  const showToast = useCallback((msg: string) => {
    setToast(msg);
    sessionStorage.setItem(TOAST_KEY, JSON.stringify({ message: msg, expiresAt: Date.now() + 4000 }));
    if (timer.current) clearTimeout(timer.current);
    timer.current = setTimeout(() => setToast(null), 4000);
  }, []);

  useEffect(() => {
    const raw = sessionStorage.getItem(TOAST_KEY);
    if (!raw) return;
    const { message, expiresAt } = JSON.parse(raw);
    const rem = expiresAt - Date.now();
    if (rem > 0) { setToast(message); timer.current = setTimeout(() => setToast(null), rem); }
    return () => { if (timer.current) clearTimeout(timer.current); };
  }, []);

  const setLoad = (key: keyof typeof loading, val: boolean) => setLoading(prev => ({ ...prev, [key]: val }));

  const runImport = async () => {
    setLoad(source, true); setMessage(null);
    try {
      const res = await fetch(`/api/import?source=${source}`, { method: "POST" });
      const json = await res.json();
      if (res.status === 409) throw new Error(json.error || "A sync is already in progress.");
      if (!res.ok) throw new Error(json.error || "Import failed");
      setMessage(json.message || `Imported ${json.imported} new items.`);
      router.refresh();
    } catch (e) {
      setMessage(e instanceof Error ? e.message : String(e));
    } finally {
      setLoad(source, false);
    }
  };

  const runEnrich = async (full = false) => {
    const key = source === "x" ? "enrichX" : "enrichYt";
    setLoad(key, true); setMessage("Starting...");
    try {
      let runId: string | undefined;
      let totalUpdated = 0;
      let totalProcessed = 0;
      let remaining = 0;
      let errorsCount = 0;

      while (true) {
        const limit = full ? 500 : (source === "yt" ? 200 : enrichBatchSize);
        let url = `/api/enrich?source=${source}&limit=${limit}`;
        if (full) url += "&full=true";
        if (runId) url += `&runId=${runId}`;

        const res = await fetch(url, { method: "POST" });
        
        if (!res.ok) {
          if (soundOnError) playErrorSound();
          let errorMsg = "Enrich failed";
          try {
            const errorJson = await res.json();
            errorMsg = errorJson.error || errorMsg;
          } catch {
            // Not JSON, use status text
            errorMsg = `${res.status} ${res.statusText}`;
          }
          throw new Error(errorMsg);
        }

        const json = await res.json();
        if (res.status === 409) throw new Error(json.error || "Enrichment is already in progress.");

        if (!runId) runId = json.runId;
        totalUpdated += (json.updated || 0);
        totalProcessed += (json.processed || 0);
        remaining = (json.remaining || 0);
        errorsCount += (json.errors?.length || 0);

        if (json.errors?.length > 0 && soundOnError) playErrorSound();
        
        // If not full, or no more items processed, or all items processed, break
        if (!full || json.processed === 0 || remaining === 0) {
          if (full && soundOnComplete && totalProcessed > 0) playSuccessSound();
          const sum = `Enriched ${totalUpdated}/${totalProcessed}. Remaining: ${remaining}. Errors: ${errorsCount}.`;
          setMessage(sum);
          showToast("Processing finished.");
          break;
        }
        
        setMessage(`Enriched ${totalUpdated} so far... ${remaining} remaining.`);
      }
      router.refresh();
    } catch (e) {
      setMessage(e instanceof Error ? e.message : String(e));
    } finally {
      setLoad(key, false);
    }
  };

  return { loading, message, toast, runImport, runEnrich };
}
