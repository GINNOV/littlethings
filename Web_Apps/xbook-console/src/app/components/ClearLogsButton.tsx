"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import ConfirmationDialog from "./ConfirmationDialog";

export default function ClearLogsButton() {
  const [loading, setLoading] = useState(false);
  const [isDialogOpen, setIsOpen] = useState(false);
  const [errorMsg, setError] = useState<string | null>(null);
  const router = useRouter();

  const handleClear = async () => {
    setLoading(true); setError(null);
    try {
      const res = await fetch("/api/processing/clear", { method: "POST" });
      if (res.ok) router.refresh();
      else setError("Failed to clear logs.");
    } catch {
      setError("An error occurred while clearing logs.");
    } finally { setLoading(false); }
  };

  return (
    <>
      <button onClick={() => setIsOpen(true)} disabled={loading} className="rounded-md border border-error px-4 py-2 text-sm font-semibold text-error transition hover:bg-error hover:text-white disabled:opacity-50">
        {loading ? "Clearing..." : "Clear history"}
      </button>
      {errorMsg && <p className="text-xs text-error font-bold mt-1 uppercase">{errorMsg}</p>}
      <ConfirmationDialog isOpen={isDialogOpen} onClose={() => setIsOpen(false)} onConfirm={handleClear} title="Clear Processing History" message="Are you sure you want to clear your processing history? This will only delete completed, failed, or stopped jobs. Active operations will be preserved." confirmLabel="Clear History" variant="danger" />
    </>
  );
}
