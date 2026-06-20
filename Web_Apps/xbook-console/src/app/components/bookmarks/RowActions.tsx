import { Bookmark } from "../../hooks/useBookmarksList";

type Props = { b: Bookmark; busy: boolean; onToggleRead: any; onEdit: any; };

export function RowActions({ b, busy, onToggleRead, onEdit }: Props) {
  const btn = "rounded-md bg-surface-container-high px-2 py-1 text-xs font-semibold disabled:opacity-60";
  return (
    <span className="flex justify-end gap-2">
      <button type="button" disabled={busy} className={btn} onClick={(e) => { e.stopPropagation(); onToggleRead(b); }}>
        {b.readAt ? "Unread" : "Read"}
      </button>
      <button type="button" className={btn} onClick={(e) => { e.stopPropagation(); onEdit(b); }}>
        Edit
      </button>
    </span>
  );
}
