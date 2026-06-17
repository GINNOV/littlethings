"use client";

import { EditState } from "../hooks/useBookmarksList";

type Props = {
  editing: EditState;
  onClose: () => void;
  onSave: () => Promise<void>;
  setEditing: React.Dispatch<React.SetStateAction<EditState>>;
  isBusy: boolean;
};

export function EditEnrichmentDialog({
  editing,
  onClose,
  onSave,
  setEditing,
  isBusy,
}: Props) {
  if (!editing) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4">
      <div className="w-full max-w-xl rounded-lg border border-outline-variant bg-surface p-6 shadow-xl">
        <div className="flex items-center justify-between">
          <h3 className="text-lg font-semibold">Edit enrichment</h3>
          <button
            type="button"
            onClick={onClose}
            className="text-sm font-semibold text-on-surface-variant hover:text-on-surface"
          >
            Close
          </button>
        </div>
        <div className="mt-4 space-y-3">
          <div className="space-y-2">
            <label className="text-sm font-semibold">Summary</label>
            <textarea
              value={editing.summary}
              onChange={(event) =>
                setEditing((prev) =>
                  prev ? { ...prev, summary: event.target.value } : prev
                )
              }
              className="min-h-[140px] w-full rounded-md border border-outline-variant bg-surface-container-lowest px-4 py-3 text-sm"
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-semibold">Category</label>
            <input
              type="text"
              value={editing.category}
              onChange={(event) =>
                setEditing((prev) =>
                  prev ? { ...prev, category: event.target.value } : prev
                )
              }
              className="w-full rounded-md border border-outline-variant bg-surface-container-lowest px-4 py-2 text-sm"
            />
          </div>
          <div className="space-y-2">
            <label className="text-sm font-semibold">Tags</label>
            <input
              type="text"
              value={editing.tags}
              onChange={(event) =>
                setEditing((prev) =>
                  prev ? { ...prev, tags: event.target.value } : prev
                )
              }
              placeholder="comma-separated"
              className="w-full rounded-md border border-outline-variant bg-surface-container-lowest px-4 py-2 text-sm"
            />
          </div>
        </div>
        <div className="mt-5 flex flex-wrap items-center gap-3">
          <button
            type="button"
            onClick={onSave}
            disabled={isBusy}
            className="rounded-md bg-primary px-4 py-2 text-sm font-semibold text-white transition disabled:opacity-60"
          >
            {isBusy ? "Saving..." : "Save"}
          </button>
          <button
            type="button"
            onClick={onClose}
            className="rounded-md border border-outline-variant px-4 py-2 text-sm font-semibold text-on-surface transition"
          >
            Cancel
          </button>
        </div>
      </div>
    </div>
  );
}
