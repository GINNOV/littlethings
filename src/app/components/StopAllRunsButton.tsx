"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import ConfirmationDialog from "./ConfirmationDialog";

export default function StopAllRunsButton() {
  const [loading, setLoading] = useState(false);
  const [isDialogOpen, setIsOpen] = useState(false);
  const [errorMsg, setError] = useState<string | null>(null);
  const router = useRouter();

  const handleStopAll = async () => {
    setLoading(true); setError(null);
    try {
      const res = await fetch("/api/processing/runs/stop-all", { method: "POST" });
      if (res.ok) router.refresh();
      else {
        const json = await res.json();
        setError(json.error ?? "Failed to stop all runs.");
      }
    } catch {
      setError("An error occurred while stopping operations.");
    } finally { setLoading(false); }
  };

  return (
    <>
      <button onClick={() => setIsOpen(true)} disabled={loading} className="rounded-md border border-error px-4 py-2 text-sm font-semibold text-error transition hover:bg-error hover:text-white disabled:opacity-50">
        {loading ? "Stopping..." : "Stop all operations"}
      </button>
      {errorMsg && <p className="text-xs text-error font-bold mt-1 uppercase">{errorMsg}</p>}
      <ConfirmationDialog isOpen={isDialogOpen} onClose={() => setIsOpen(false)} onConfirm={handleStopAll} title="Stop All Operations" message="Are you sure you want to stop all active operations? This will halt any background processing immediately." confirmLabel="Stop All" variant="danger" />
    </>
  );
}
