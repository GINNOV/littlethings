"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { playSuccessSound, playErrorSound } from "@/lib/audio";

const TOAST_KEY = "xbook:actions-toast";

function isAbortError(e: unknown) {
  return e instanceof DOMException
    ? e.name === "AbortError"
    : e instanceof Error && e.name === "AbortError";
}

/** Parse JSON without throwing the opaque "Unexpected end of JSON input" on empty bodies. */
async function readJson(res: Response): Promise<any> {
  const text = await res.text();
  if (!text.trim()) {
    throw new Error(
      res.ok
        ? `Empty response from server (${res.status}). The request may have timed out — try again.`
        : `Server error ${res.status} ${res.statusText || ""}`.trim()
    );
  }
  try {
    return JSON.parse(text);
  } catch {
    throw new Error(
      `Invalid JSON from server (${res.status}): ${text.slice(0, 160).replace(/\s+/g, " ")}`
    );
  }
}

type FetchJsonOptions = {
  method?: string;
  signal?: AbortSignal;
  /** Transient empty/timeout bodies are retried this many extra times. */
  retries?: number;
};

async function fetchJson(url: string, options: FetchJsonOptions = {}): Promise<{ res: Response; json: any }> {
  const retries = options.retries ?? 0;
  let lastError: Error | null = null;

  for (let attempt = 0; attempt <= retries; attempt++) {
    if (options.signal?.aborted) throw new DOMException("Aborted", "AbortError");
    try {
      const res = await fetch(url, { method: options.method ?? "GET", signal: options.signal });
      const json = await readJson(res);
      return { res, json };
    } catch (e) {
      if (isAbortError(e)) throw e;
      lastError = e instanceof Error ? e : new Error(String(e));
      const retriable =
        /Empty response|timed out|Failed to fetch|NetworkError|network/i.test(lastError.message) ||
        /Invalid JSON/i.test(lastError.message);
      if (!retriable || attempt === retries) throw lastError;
      // Brief backoff before retrying a flaky long request.
      await new Promise((r) => setTimeout(r, 500 * (attempt + 1)));
    }
  }
  throw lastError ?? new Error("Request failed");
}

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
  const [cancelling, setCancelling] = useState(false);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);
  /** Client-side multi-batch loop cancel (stops further POSTs). */
  const abortRef = useRef<AbortController | null>(null);
  /** Server operation run to stop when the user cancels. */
  const activeRunIdRef = useRef<string | null>(null);

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

  const beginClientOp = () => {
    abortRef.current?.abort();
    const controller = new AbortController();
    abortRef.current = controller;
    activeRunIdRef.current = null;
    return controller;
  };

  const endClientOp = (controller: AbortController) => {
    if (abortRef.current === controller) {
      abortRef.current = null;
      activeRunIdRef.current = null;
    }
  };

  const trackRunId = (runId?: string | null) => {
    if (runId) activeRunIdRef.current = runId;
  };

  /**
   * Stop the in-flight inbox/enrich/sync work so another operation can start.
   * Stops the server run first (so multi-batch will not revive it), then aborts
   * the client loop that would otherwise keep POSTing the next batch.
   */
  const cancelOperation = async () => {
    setCancelling(true);
    setMessage("Stopping…");
    const runId = activeRunIdRef.current;
    try {
      if (runId) {
        await fetch(`/api/processing/runs/${runId}`, { method: "POST" });
      } else {
        // Sync / early inbox phase may not have a run id yet — clear any active ops.
        await fetch("/api/processing/runs/stop-all", { method: "POST" });
      }
    } catch {
      // Best-effort; client abort still unblocks the UI.
    } finally {
      abortRef.current?.abort();
      setCancelling(false);
    }
  };

  const runImport = async () => {
    const controller = beginClientOp();
    setLoad(source, true);
    setMessage(null);
    try {
      const { res, json } = await fetchJson(`/api/import?source=${source}`, {
        method: "POST",
        signal: controller.signal,
        retries: 1,
      });
      if (res.status === 409) throw new Error(json.error || "A sync is already in progress.");
      if (!res.ok) throw new Error(json.error || "Import failed");
      if (json.operationId || json.runId) trackRunId(json.operationId ?? json.runId);
      setMessage(
        json.message ||
          (json.imported
            ? `Imported ${json.imported} new item${json.imported === 1 ? "" : "s"}.`
            : "No new items.")
      );
      if (soundOnComplete && (json.imported ?? 0) > 0) playSuccessSound();
      router.refresh();
      return json;
    } catch (e) {
      if (isAbortError(e)) {
        setMessage("Stopped.");
        showToast("Operation stopped.");
        router.refresh();
        return null;
      }
      setMessage(e instanceof Error ? e.message : String(e));
      return null;
    } finally {
      setLoad(source, false);
      endClientOp(controller);
    }
  };

  const runEnrich = async (full = false, reprocess = false) => {
    const key = source === "x" ? "enrichX" : "enrichYt";
    const controller = beginClientOp();
    setLoad(key, true);
    setMessage("Starting...");
    try {
      let runId: string | undefined;
      let totalUpdated = 0;
      let totalProcessed = 0;
      let remaining = 0;
      let errorsCount = 0;
      let stopped = false;

      while (!controller.signal.aborted) {
        const limit = full ? 500 : source === "yt" ? 200 : enrichBatchSize;
        let url = `/api/enrich?source=${source}&limit=${limit}`;
        if (full) url += "&full=true";
        if (reprocess) url += "&reprocess=true";
        if (runId) url += `&runId=${runId}`;

        const { res, json } = await fetchJson(url, {
          method: "POST",
          signal: controller.signal,
          retries: 2,
        });

        if (json?.stopped || (typeof json?.error === "string" && json.error.includes("stopped"))) {
          stopped = true;
          trackRunId(json.runId);
          break;
        }

        if (!res.ok) {
          if (res.status === 409 && json?.stopped) {
            stopped = true;
            break;
          }
          if (soundOnError) playErrorSound();
          throw new Error(json?.error || `Enrich failed (${res.status})`);
        }

        if (!runId) runId = json.runId;
        trackRunId(runId);
        const batchProcessed = Number(json.processed) || 0;
        const batchUpdated = Number(json.updated) || 0;
        const batchRemaining = Number(json.remaining);
        totalUpdated += batchUpdated;
        totalProcessed += batchProcessed;
        // Prefer explicit remaining; only fall back to 0 when the server said finished.
        remaining = Number.isFinite(batchRemaining)
          ? batchRemaining
          : json.finished
            ? 0
            : remaining;
        errorsCount += Array.isArray(json.errors) ? json.errors.length : 0;

        if (json.errors?.length > 0 && soundOnError) playErrorSound();

        const batchLabel =
          json.batch && json.batches
            ? `Batch ${json.batch} of ${json.batches}`
            : null;

        // Single-batch mode always stops after one request.
        // Full mode continues while the server reports more remaining work.
        const moreWork = full && !json.stopped && !json.finished && remaining > 0 && batchProcessed > 0;
        if (!moreWork) {
          if (json.stopped) {
            stopped = true;
            break;
          }
          if (full && soundOnComplete && totalProcessed > 0 && remaining === 0) playSuccessSound();
          const sum =
            (batchLabel ? `${batchLabel} · ` : "") +
            `Enriched ${totalUpdated}/${totalProcessed}. Remaining: ${remaining}. Errors: ${errorsCount}.`;
          setMessage(sum);
          showToast(remaining > 0 ? "Enrichment paused with items still pending." : "Processing finished.");
          break;
        }

        setMessage(
          (batchLabel ? `${batchLabel} · ` : "") +
            `${totalUpdated} updated so far · ${remaining} remaining…`
        );
      }

      if (controller.signal.aborted || stopped) {
        setMessage(
          `Stopped. Enriched ${totalUpdated}/${totalProcessed} before cancel.` +
            (errorsCount ? ` Errors: ${errorsCount}.` : "")
        );
        showToast("Operation stopped.");
      }
      router.refresh();
      return { totalUpdated, totalProcessed, remaining, errorsCount, stopped };
    } catch (e) {
      if (isAbortError(e)) {
        setMessage("Stopped.");
        showToast("Operation stopped.");
        router.refresh();
        return null;
      }
      setMessage(e instanceof Error ? e.message : String(e));
      return null;
    } finally {
      setLoad(key, false);
      endClientOp(controller);
    }
  };

  /** Delta import then enrich all pending for this source, then best-effort embeddings. */
  const runProcessInbox = async () => {
    const key = source === "x" ? "inboxX" : "inboxYt";
    const controller = beginClientOp();
    setLoad(key, true);
    setMessage("Processing inbox: syncing…");
    try {
      let imported = 0;
      let importWarning: string | null = null;

      try {
        const { res, json } = await fetchJson(`/api/import?source=${source}`, {
          method: "POST",
          signal: controller.signal,
          retries: 1,
        });
        if (res.status === 409) throw new Error(json.error || "A sync is already in progress.");
        if (!res.ok) throw new Error(json.error || "Import failed");
        if (json.operationId || json.runId) trackRunId(json.operationId ?? json.runId);
        imported = json.imported ?? json.created ?? 0;
      } catch (e) {
        if (isAbortError(e)) throw e;
        // Keep going into enrich so existing pending items still get processed
        // when sync returns an empty/timeout body (common on long X imports).
        importWarning = e instanceof Error ? e.message : String(e);
        setMessage(`Sync issue (${importWarning}). Continuing with enrichment of existing pending…`);
      }

      if (controller.signal.aborted) throw new DOMException("Aborted", "AbortError");

      if (!importWarning) {
        setMessage(`Sync done (${imported} new). Enriching pending…`);
      }

      let runId: string | undefined;
      let totalUpdated = 0;
      let totalProcessed = 0;
      let remaining = 0;
      let errorsCount = 0;
      let stopped = false;

      while (!controller.signal.aborted) {
        const limit = source === "yt" ? 200 : Math.max(enrichBatchSize, 50);
        let url = `/api/enrich?source=${source}&limit=${limit}&full=true`;
        if (runId) url += `&runId=${runId}`;

        const { res, json } = await fetchJson(url, {
          method: "POST",
          signal: controller.signal,
          retries: 2,
        });

        if (json?.stopped || (res.status === 409 && json?.stopped)) {
          stopped = true;
          trackRunId(json?.runId);
          break;
        }

        if (!res.ok) {
          if (soundOnError) playErrorSound();
          throw new Error(json?.error || `Enrich failed (${res.status})`);
        }

        if (!runId) runId = json.runId;
        trackRunId(runId);
        const batchProcessed = Number(json.processed) || 0;
        const batchUpdated = Number(json.updated) || 0;
        const batchRemaining = Number(json.remaining);
        totalUpdated += batchUpdated;
        totalProcessed += batchProcessed;
        remaining = Number.isFinite(batchRemaining)
          ? batchRemaining
          : json.finished
            ? 0
            : remaining;
        errorsCount += Array.isArray(json.errors) ? json.errors.length : 0;

        const moreWork = !json.stopped && !json.finished && remaining > 0 && batchProcessed > 0;
        if (!moreWork) {
          if (json.stopped) stopped = true;
          break;
        }
        setMessage(`Inbox enriching… ${totalUpdated} done, ${remaining} remaining.`);
      }

      if (controller.signal.aborted || stopped) {
        setMessage(
          `Stopped after inbox sync (${imported} new). Enriched ${totalUpdated}/${totalProcessed} before cancel.`
        );
        showToast("Operation stopped.");
        router.refresh();
        return;
      }

      let embedMsg = "";
      try {
        let embUpdated = 0;
        let embFailed = 0;
        let embRemaining = 0;
        for (let round = 0; round < 100 && !controller.signal.aborted; round++) {
          const { res: embRes, json: embJson } = await fetchJson(
            `/api/bookmarks/embeddings/sync?limit=100&source=${source}`,
            { method: "POST", signal: controller.signal, retries: 1 }
          );
          if (!embRes.ok) break;
          if (embJson.runId) trackRunId(embJson.runId);
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
      } catch (e) {
        if (isAbortError(e)) throw e;
        // Non-fatal — enrichment already completed.
      }

      if (controller.signal.aborted) throw new DOMException("Aborted", "AbortError");

      if (soundOnComplete && (totalProcessed > 0 || imported > 0)) playSuccessSound();
      const warn = importWarning ? ` Sync warning: ${importWarning}.` : "";
      const sum = `Inbox: ${imported} new · enriched ${totalUpdated}/${totalProcessed} · remaining ${remaining} · errors ${errorsCount}.${embedMsg}${warn}`;
      setMessage(sum);
      showToast(
        remaining > 0
          ? "Inbox finished with items still pending."
          : "Inbox processing finished."
      );
      router.refresh();
    } catch (e) {
      if (isAbortError(e)) {
        setMessage("Stopped.");
        showToast("Operation stopped.");
        router.refresh();
        return;
      }
      if (soundOnError) playErrorSound();
      setMessage(e instanceof Error ? e.message : String(e));
    } finally {
      setLoad(key, false);
      endClientOp(controller);
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
    const controller = beginClientOp();
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
        const { res, json } = await fetchJson(
          `/api/bookmarks/embeddings/sync?limit=100${scope}`,
          { method: "POST", signal: controller.signal, retries: 1 }
        );
        if (!res.ok) throw new Error(json.error || json.message || "Embedding sync failed");
        if (json.runId) trackRunId(json.runId);

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
      if (isAbortError(e)) {
        setMessage("Stopped.");
        showToast("Operation stopped.");
        router.refresh();
        return null;
      }
      if (soundOnError) playErrorSound();
      setMessage(e instanceof Error ? e.message : String(e));
      return null;
    } finally {
      setLoad("embeddings", false);
      endClientOp(controller);
    }
  };

  return {
    loading,
    message,
    toast,
    cancelling,
    runImport,
    runEnrich,
    runProcessInbox,
    runSyncEmbeddings,
    cancelOperation,
  };
}
