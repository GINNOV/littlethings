"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { playSuccessSound, playErrorSound } from "@/lib/audio";

type Folder = {
  id: string;
  name?: string | null;
  total?: number;
};

type Props = {
  folders: Folder[];
  soundOnComplete?: boolean;
  soundOnError?: boolean;
};

export default function YouTubeFoldersPanel({ folders, soundOnComplete, soundOnError }: Props) {
  const router = useRouter();
  const [syncing, setSyncing] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [isError, setIsError] = useState(false);
  const [processing, setProcessing] = useState<string | null>(null);

  const syncPlaylists = async () => {
    setSyncing(true);
    setMessage(null);
    setIsError(false);
    try {
      const res = await fetch("/api/youtube/folders/sync", { method: "POST" });
      const json = await res.json();
      if (!res.ok) throw new Error(json.error ?? "YouTube playlist sync failed");
      setMessage(`Synced ${json.total} playlists. Reloading…`);
      window.location.reload();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "YouTube playlist sync failed");
      setIsError(true);
    } finally {
      setSyncing(false);
    }
  };

  const processFolder = async (folderId: string) => {
    setProcessing(folderId);
    setMessage(null);
    setIsError(false);
    try {
      let currentRunId: string | null = null;
      let totalProcessed = 0;
      let totalUpdated = 0;
      let totalErrors = 0;
      let batches = 0;
      let haltedOnErrors = false;

      while (batches < 50) {
        const baseUrl = `/api/enrich?source=yt&folderId=${encodeURIComponent(folderId)}&limit=200`;
        const enrichUrl: string = currentRunId ? `${baseUrl}&runId=${currentRunId}` : baseUrl;

        const res = await fetch(enrichUrl, { method: "POST" });
        const json = await res.json();
        if (!res.ok) {
          if (soundOnError) playErrorSound();
          throw new Error(json.error ?? "Playlist processing failed");
        }

        if (!currentRunId && json.runId) {
          currentRunId = json.runId;
        }

        const processed = Number(json.processed ?? 0);
        const updated = Number(json.updated ?? 0);
        const errorCount = Array.isArray(json.errors) ? json.errors.length : 0;
        totalProcessed += processed;
        totalUpdated += updated;
        totalErrors += errorCount;
        batches += 1;

        if (errorCount > 0 && soundOnError) {
          playErrorSound();
        }

        if (processed === 0) break;
        if (errorCount > 0 && errorCount === processed) {
          haltedOnErrors = true;
          break;
        }
      }

      if (soundOnComplete && !haltedOnErrors) {
        playSuccessSound();
      }

      setMessage(
        `Processed playlist: ${totalUpdated}/${totalProcessed} updated across ${batches} batch(es). Errors: ${totalErrors}.${haltedOnErrors ? " Halted to avoid retrying failed items." : ""}`
      );
      router.refresh();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Playlist processing failed");
      setIsError(true);
    } finally {
      setProcessing(null);
    }
  };

  return (
    <section className="flex flex-col gap-4 rounded-3xl border border-black/10 bg-white/70 p-6 shadow-sm">
      {message ? (
        <div className={`rounded-lg p-3 text-sm font-semibold mb-2 shadow-sm border ${isError ? "bg-red-50 text-red-800 border-red-100" : "bg-emerald-50 text-emerald-800 border-emerald-100"}`}>
          {message}
        </div>
      ) : null}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h2 className="text-2xl font-semibold">YouTube playlists</h2>
        <button
          type="button"
          onClick={syncPlaylists}
          disabled={syncing}
          className="rounded-full border border-black/10 px-4 py-2 text-sm font-semibold text-slate-800 transition disabled:opacity-60"
        >
          {syncing ? "Syncing…" : "Sync playlists"}
        </button>
      </div>
      {folders.length ? (
        <div className="overflow-hidden rounded-lg border border-black/10">
          <table className="w-full text-left text-sm">
            <thead className="bg-surface-container text-xs font-bold uppercase tracking-wider text-on-surface-variant">
              <tr>
                <th className="px-4 py-2">Playlist Name</th>
                <th className="px-4 py-2">Videos</th>
                <th className="px-4 py-2 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-black/5 bg-white">
              {folders.map((folder) => (
                <tr key={folder.id} className="hover:bg-slate-50 transition-colors">
                  <td className="px-4 py-3 font-semibold">
                    {folder.name ?? "Unknown playlist"}
                  </td>
                  <td className="px-4 py-3 text-slate-500">
                    {folder.total ?? 0}
                  </td>
                  <td className="px-4 py-3 text-right">
                    <button
                      type="button"
                      onClick={() => processFolder(folder.id)}
                      disabled={processing === folder.id}
                      className="rounded-full border border-black/10 px-3 py-1 text-xs font-bold uppercase text-slate-700 transition hover:bg-black hover:text-white disabled:opacity-60"
                    >
                      {processing === folder.id ? "..." : "Process"}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <p className="text-sm text-slate-600">No playlists yet. Sync to load them.</p>
      )}
    </section>
  );
}
