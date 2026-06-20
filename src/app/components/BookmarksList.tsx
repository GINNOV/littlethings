"use client";

import { useBookmarksList, Bookmark } from "../hooks/useBookmarksList";
import { BookmarkRow } from "./BookmarkRow";
import { BookmarkInspector } from "./BookmarkInspector";
import { EditEnrichmentDialog } from "./EditEnrichmentDialog";

type Props = {
  initial: Bookmark[];
};

export default function BookmarksList({ initial }: Props) {
  const {
    items,
    busyId,
    message,
    editing,
    setEditing,
    selectedId,
    setSelectedId,
    translatedText,
    isTranslating,
    translate,
    reprocess,
    toggleRead,
    openEdit,
    closeEdit,
    saveEdit,
    selected,
  } = useBookmarksList(initial);

  const getYouTubeTitle = (bookmark: Bookmark) => {
    if (bookmark.source !== "yt") return null;
    try {
      const parsed = JSON.parse(bookmark.rawJson ?? "{}") as {
        item?: { snippet?: { title?: string } };
      };
      const byJson = parsed.item?.snippet?.title?.trim();
      if (byJson) return byJson;
    } catch {}
    const byText = bookmark.text?.split("\n")[0]?.trim();
    return byText || null;
  };

  const getYouTubeFolder = (bookmark: Bookmark) => {
    if (bookmark.source !== "yt") return bookmark.folderName ?? null;
    if (bookmark.folderName?.trim()) return bookmark.folderName.trim();
    try {
      const parsed = JSON.parse(bookmark.rawJson ?? "{}") as {
        playlistTitle?: string;
      };
      return parsed.playlistTitle?.trim() ?? null;
    } catch {
      return null;
    }
  };

  return (
    <div className="flex flex-col gap-4">
      {message ? <p className="text-sm text-on-surface-variant">{message}</p> : null}
      <section className={`grid gap-4 ${selected ? "xl:grid-cols-[minmax(0,1fr)_380px]" : "grid-cols-1"}`}>
        <div className="overflow-x-auto rounded-lg bg-surface-container-lowest border border-outline-variant/30">
          <div className="min-w-[1200px]">
            <div className="grid min-w-[1200px] grid-cols-[44px_150px_minmax(220px,1fr)_150px_150px_100px_90px_90px_140px] bg-surface-container px-4 py-2 text-xs font-semibold uppercase text-on-surface-variant">
              <span></span>
              <span>Category</span>
              <span>{items[0]?.source === "yt" ? "Video / digest" : "Summary"}</span>
              <span>{items[0]?.source === "yt" ? "Channel" : "Author"}</span>
              <span>Folder</span>
              <span>Status</span>
              <span>Posted</span>
              <span>Import</span>
              <span className="text-right">Actions</span>
            </div>
            <div className="divide-y divide-[color-mix(in_srgb,var(--outline-variant)_25%,transparent)]">
              {items.map((bookmark) => (
                <BookmarkRow
                  key={bookmark.id}
                  bookmark={bookmark}
                  isSelected={selectedId === bookmark.id}
                  onSelect={setSelectedId}
                  onToggleRead={toggleRead}
                  onEdit={openEdit}
                  isBusy={busyId === bookmark.id}
                  getYouTubeTitle={getYouTubeTitle}
                  getYouTubeFolder={getYouTubeFolder}
                />
              ))}
              {items.length === 0 ? (
                <p className="px-4 py-8 text-sm text-on-surface-variant">
                  No bookmarks match the current filters.
                </p>
              ) : null}
            </div>
          </div>
        </div>

        {selected && (
          <BookmarkInspector
            selected={selected}
            translatedText={translatedText}
            isTranslating={isTranslating}
            busyId={busyId}
            onTranslate={translate}
            onReprocess={reprocess}
            onEdit={openEdit}
            onClose={() => setSelectedId(null)}
            getYouTubeTitle={getYouTubeTitle}
          />
        )}
      </section>

      <EditEnrichmentDialog
        editing={editing}
        onClose={closeEdit}
        onSave={saveEdit}
        setEditing={setEditing}
        isBusy={busyId === editing?.id}
      />
    </div>
  );
}
