"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { playSuccessSound, playErrorSound } from "@/lib/audio";

const TOAST_KEY = "xbook:actions-toast";

export function useActions(source: "x" | "yt", enrichBatchSize: number, soundOnComplete?: boolean, soundOnError?: boolean) {
  const router = useRouter();
  const [loading, setLoading] = useState({
    x: false,
    yt: false,
    enrichX: false,
    enrichYt: false,
    inboxX: false,
    inboxYt: false,
    embeddings: false,
  });
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
    if (rem > 0) {
      setToast(message);
      timer.current = setTimeout(() => setToast(null), rem);
    }
    return () => {
      if (timer.current) clearTimeout(timer.current);
    };
  }, []);

  const setLoad = (key: keyof typeof loading, val: boolean) => setLoading((prev) => ({ ...prev, [key]: val }));

  const runImport = async () => {
    setLoad(source, true);
    setMessage(null);
    try {
      const res = await fetch(`/api/import?source=${source}`, { method: "POST" });
      const json = await res.json();
      if (res.status === 409) throw new Error(json.error || "A sync is already in progress.");
      if (!res.ok) throw new Error(json.error || "Import failed");
      setMessage(json.message || `Imported ${json.imported} new items.`);
      router.refresh();
      return json;
    } catch (e) {
      setMessage(e instanceof Error ? e.message : String(e));
      return null;
    } finally {
      setLoad(source, false);
    }
  };

  const runEnrich = async (full = false, reprocess = false) => {
    const key = source === "x" ? "enrichX" : "enrichYt";
    setLoad(key, true);
    setMessage("Starting...");
    try {
      let runId: string | undefined;
      let totalUpdated = 0;
      let totalProcessed = 0;
      let remaining = 0;
      let errorsCount = 0;

      while (true) {
        const limit = full ? 500 : source === "yt" ? 200 : enrichBatchSize;
        let url = `/api/enrich?source=${source}&limit=${limit}`;
        if (full) url += "&full=true";
        if (reprocess) url += "&reprocess=true";
        if (runId) url += `&runId=${runId}`;

        const res = await fetch(url, { method: "POST" });

        if (!res.ok) {
          if (soundOnError) playErrorSound();
          let errorMsg = "Enrich failed";
          try {
            const errorJson = await res.json();
            errorMsg = errorJson.error || errorMsg;
          } catch {
            errorMsg = `${res.status} ${res.statusText}`;
          }
          throw new Error(errorMsg);
        }

        const json = await res.json();
        if (res.status === 409) throw new Error(json.error || "Enrichment is already in progress.");

        if (!runId) runId = json.runId;
        totalUpdated += json.updated || 0;
        totalProcessed += json.processed || 0;
        remaining = json.remaining || 0;
        errorsCount += json.errors?.length || 0;

        if (json.errors?.length > 0 && soundOnError) playErrorSound();

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
      return { totalUpdated, totalProcessed, remaining, errorsCount };
    } catch (e) {
      setMessage(e instanceof Error ? e.message : String(e));
      return null;
    } finally {
      setLoad(key, false);
    }
  };

  /** Delta import then enrich all pending for this source, then best-effort embeddings. */
  const runProcessInbox = async () => {
    const key = source === "x" ? "inboxX" : "inboxYt";
    setLoad(key, true);
    setMessage("Processing inbox: syncing…");
    try {
      const importJson = await (async () => {
        const res = await fetch(`/api/import?source=${source}`, { method: "POST" });
        const json = await res.json();
        if (res.status === 409) throw new Error(json.error || "A sync is already in progress.");
        if (!res.ok) throw new Error(json.error || "Import failed");
        return json;
      })();

      const imported = importJson.imported ?? importJson.created ?? 0;
      setMessage(`Sync done (${imported} new). Enriching pending…`);

      let runId: string | undefined;
      let totalUpdated = 0;
      let totalProcessed = 0;
      let remaining = 0;
      let errorsCount = 0;

      while (true) {
        const limit = source === "yt" ? 200 : Math.max(enrichBatchSize, 50);
        let url = `/api/enrich?source=${source}&limit=${limit}&full=true`;
        if (runId) url += `&runId=${runId}`;

        const res = await fetch(url, { method: "POST" });
        if (!res.ok) {
          if (soundOnError) playErrorSound();
          let errorMsg = "Enrich failed";
          try {
            const errorJson = await res.json();
            errorMsg = errorJson.error || errorMsg;
          } catch {
            errorMsg = `${res.status} ${res.statusText}`;
          }
          throw new Error(errorMsg);
        }

        const json = await res.json();
        if (!runId) runId = json.runId;
        totalUpdated += json.updated || 0;
        totalProcessed += json.processed || 0;
        remaining = json.remaining || 0;
        errorsCount += json.errors?.length || 0;

        if (json.processed === 0 || remaining === 0) break;
        setMessage(`Inbox enriching… ${totalUpdated} done, ${remaining} remaining.`);
      }

      let embedMsg = "";
      try {
        let embUpdated = 0;
        let embFailed = 0;
        let embRemaining = 0;
        for (let round = 0; round < 100; round++) {
          const embRes = await fetch(
            `/api/bookmarks/embeddings/sync?limit=100&source=${source}`,
            { method: "POST" }
          );
          const embJson = await embRes.json();
          if (!embRes.ok) break;
          embUpdated += embJson.updated ?? 0;
          embFailed += embJson.failed ?? 0;
          embRemaining = embJson.remaining ?? 0;
          if ((embJson.updated ?? 0) + (embJson.failed ?? 0) === 0 || embRemaining === 0) break;
          setMessage(
            `Inbox indexing… ${embUpdated.toLocaleString()} done` +
              (embRemaining > 0 ? `, ${embRemaining.toLocaleString()} remaining` : "") +
              "…"
          );
        }
        if (embUpdated || embFailed) {
          embedMsg =
            ` Indexed ${embUpdated.toLocaleString()}` +
            (embFailed ? `, embed failures ${embFailed.toLocaleString()}` : "") +
            (embRemaining > 0 ? `, ${embRemaining.toLocaleString()} still missing` : "") +
            ".";
        }
      } catch {
        // Non-fatal — enrichment already completed.
      }

      if (soundOnComplete && (totalProcessed > 0 || imported > 0)) playSuccessSound();
      const sum = `Inbox: ${imported} new · enriched ${totalUpdated}/${totalProcessed} · remaining ${remaining} · errors ${errorsCount}.${embedMsg}`;
      setMessage(sum);
      showToast("Inbox processing finished.");
      router.refresh();
    } catch (e) {
      if (soundOnError) playErrorSound();
      setMessage(e instanceof Error ? e.message : String(e));
    } finally {
      setLoad(key, false);
    }
  };

  /**
   * Batch-sync missing embeddings until the queue is empty (or a hard stop).
   * Pass `source` to match dashboard tab counts; omit for global (Settings).
   * `onProgress` receives live totals so the UI can keep "missing" in sync with "done".
   */
  const runSyncEmbeddings = async (options?: {
    source?: "x" | "yt" | null;
    onProgress?: (p: {
      done: number;
      failed: number;
      remaining: number;
      target: number;
    }) => void;
  }) => {
    setLoad("embeddings", true);
    setMessage("Syncing embeddings…");
    try {
      let totalUpdated = 0;
      let totalFailed = 0;
      let remaining = 0;
      let target = 0;
      const maxRounds = 500;
      const scope = options?.source ? `&source=${options.source}` : "";

      for (let round = 0; round < maxRounds; round++) {
        const res = await fetch(`/api/bookmarks/embeddings/sync?limit=100${scope}`, {
          method: "POST",
        });
        const json = await res.json();
        if (!res.ok) throw new Error(json.error || json.message || "Embedding sync failed");

        const updated = json.updated ?? 0;
        const failed = json.failed ?? 0;
        remaining = json.remaining ?? 0;
        totalUpdated += updated;
        totalFailed += failed;

        // First non-empty batch establishes the original queue size for "N of T".
        if (round === 0 || target === 0) {
          target = totalUpdated + totalFailed + remaining;
        }

        // No work left, or this batch made no progress (failed items stay in the
        // queue ordered the same way — retrying forever would hang the UI).
        if (updated === 0 && failed === 0) break;
        if (remaining === 0) break;

        options?.onProgress?.({
          done: totalUpdated,
          failed: totalFailed,
          remaining,
          target,
        });

        setMessage(
          `Indexing embeddings… ${totalUpdated.toLocaleString()} of ${target.toLocaleString()}` +
            (remaining > 0 ? ` · ${remaining.toLocaleString()} remaining` : "") +
            (totalFailed > 0 ? ` · ${totalFailed.toLocaleString()} failed` : "") +
            "…"
        );

        if (updated === 0) break;
        if (updated + failed < 100) break;
      }

      if (soundOnComplete && totalUpdated > 0) playSuccessSound();
      if (soundOnError && totalFailed > 0 && totalUpdated === 0) playErrorSound();

      const sum =
        totalUpdated === 0 && totalFailed === 0
          ? "No bookmarks need embedding sync."
          : `Indexed ${totalUpdated.toLocaleString()} of ${Math.max(target, totalUpdated).toLocaleString()}` +
            (totalFailed > 0 ? `, ${totalFailed.toLocaleString()} failed` : "") +
            (remaining > 0 ? `, ${remaining.toLocaleString()} still missing` : "") +
            ".";
      setMessage(sum);
      showToast(totalUpdated > 0 ? "Embedding sync finished." : "Nothing to index.");
      router.refresh();
      return { totalUpdated, totalFailed, remaining, target };
    } catch (e) {
      if (soundOnError) playErrorSound();
      setMessage(e instanceof Error ? e.message : String(e));
      return null;
    } finally {
      setLoad("embeddings", false);
    }
  };

  return { loading, message, toast, runImport, runEnrich, runProcessInbox, runSyncEmbeddings };
}
