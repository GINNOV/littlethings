"use client";

import { Bookmark } from "../hooks/useBookmarksList";
import { SourceIcon } from "./bookmarks/SourceIcon";
import { StatusColumn } from "./bookmarks/StatusColumn";
import { RowActions } from "./bookmarks/RowActions";

type Props = {
  bookmark: Bookmark; isSelected: boolean; onSelect: (id: string) => void;
  onToggleRead: (bookmark: Bookmark) => void; onEdit: (bookmark: Bookmark) => void;
  isBusy: boolean; getYouTubeTitle: (bookmark: Bookmark) => string | null; getYouTubeFolder: (bookmark: Bookmark) => string | null;
};

export function BookmarkRow({ bookmark: b, isSelected, onSelect, onToggleRead, onEdit, isBusy, getYouTubeTitle, getYouTubeFolder }: Props) {
  const title = getYouTubeTitle(b) || b.summary || b.text || "Untitled";
  const author = b.authorUsername ? (b.source === "x" ? `@${b.authorUsername}` : b.authorUsername) : "Unknown";
  // Match library status filters / dashboard: pending = empty summary only.
  // Category alone (e.g. stub "Other") is still pending enrichment.
  const status = b.summary?.trim() ? "Summarized" : "Pending";
  const fmt = (d?: Date | string | null) => d ? new Date(d).toLocaleDateString(undefined, { month: 'short', day: 'numeric' }) : "-";

  return (
    <div role="button" tabIndex={0} onClick={() => onSelect(b.id)} onKeyDown={(e) => (e.key === "Enter" || e.key === " ") && (e.preventDefault(), onSelect(b.id))}
      className={`grid min-w-[1200px] w-full grid-cols-[44px_150px_minmax(220px,1fr)_150px_150px_100px_90px_90px_140px] px-4 py-3 text-left text-sm transition hover:bg-surface-container-low ${isSelected ? "shadow-[inset_4px_0_0_var(--primary)]" : ""} ${b.readAt ? "opacity-70" : ""}`}>
      <SourceIcon source={b.source} />
      <span><span className="rounded bg-surface-container-high px-2 py-1 text-xs font-semibold">{b.category ?? "Uncategorized"}</span></span>
      <span className="truncate font-medium">{title}</span>
      <span className="truncate text-on-surface-variant">{author}</span>
      <span className="truncate text-on-surface-variant">{getYouTubeFolder(b) || b.folderName || "No folder"}</span>
      <StatusColumn status={status} edited={!!b.editedAt} error={b.error} sim={b.similarity} />
      <span className="text-xs text-on-surface-variant">{fmt(b.createdAt)}</span>
      <span className="text-xs text-on-surface-variant">{fmt(b.importedAt)}</span>
      <RowActions b={b} busy={isBusy} onToggleRead={onToggleRead} onEdit={onEdit} />
    </div>
  );
}
