"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import ConfirmationDialog from "./ConfirmationDialog";

type Props = {
  runId: string;
};

export default function StopRunButton({ runId }: Props) {
  const [loading, setLoading] = useState(false);
  const [isDialogOpen, setIsOpen] = useState(false);
  const [errorMsg, setError] = useState<string | null>(null);
  const router = useRouter();

  const handleStop = async () => {
    setLoading(true); setError(null);
    try {
      const res = await fetch(`/api/processing/runs/${runId}`, { method: "POST" });
      if (res.ok) router.refresh();
      else {
        const json = await res.json();
        setError(json.error ?? "Failed to stop run.");
      }
    } catch {
      setError("An error occurred while stopping the run.");
    } finally { setLoading(false); }
  };

  return (
    <>
      <button onClick={() => setIsOpen(true)} disabled={loading} className="rounded-md border border-error px-3 py-1 text-xs font-bold uppercase text-error transition hover:bg-error hover:text-white disabled:opacity-50">
        {loading ? "..." : "Stop"}
      </button>
      {errorMsg && <p className="text-xs text-error font-bold ml-2 uppercase inline-block">{errorMsg}</p>}
      <ConfirmationDialog isOpen={isDialogOpen} onClose={() => setIsOpen(false)} onConfirm={handleStop} title="Stop Operation" message="Are you sure you want to stop this operation? This will halt any pending items in this specific batch." confirmLabel="Stop Job" variant="danger" />
    </>
  );
}
