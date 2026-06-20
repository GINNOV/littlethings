"use client";

import { Bookmark } from "../hooks/useBookmarksList";
import { InspectorHeader } from "./inspector/InspectorHeader";
import { MetadataGrid } from "./inspector/MetadataGrid";
import { ActionButtons } from "./inspector/ActionButtons";
import { Linkify } from "./Linkify";

type Props = {
  selected: Bookmark | null; translatedText: string | null; isTranslating: boolean; busyId: string | null;
  onTranslate: (id: string) => void; onReprocess: (id: string) => void; onEdit: (bookmark: Bookmark) => void;
  onClose: () => void; getYouTubeTitle: (bookmark: Bookmark) => string | null;
};

export function BookmarkInspector({ selected, translatedText, isTranslating, busyId, onTranslate, onReprocess, onEdit, onClose, getYouTubeTitle }: Props) {
  if (!selected) return <aside className="rounded-lg bg-surface-container p-4"><p className="text-sm text-on-surface-variant">Select a bookmark to inspect it.</p></aside>;

  return (
    <aside className="rounded-lg bg-surface-container p-4 relative">
      <div className="flex flex-col gap-5">
        <InspectorHeader source={selected.source} title={selected.source === "yt" ? getYouTubeTitle(selected) : "Bookmark"} category={selected.category} folderName={selected.folderName} onClose={onClose} />
        <MetadataGrid b={selected} />
        <section>
          <h3 className="text-sm font-semibold">{selected.source === "yt" ? "Digest" : "Summary"}</h3>
          <div className="mt-2 rounded-md bg-surface-container-lowest p-3 text-sm leading-6 whitespace-pre-wrap">
            <Linkify text={selected.summary || "No summary yet."} />
          </div>
        </section>
        <section>
          <h3 className="text-sm font-semibold">Original text</h3>
          <div className="mt-2 max-h-72 overflow-auto rounded-md bg-surface-container-lowest p-3 text-sm leading-6 whitespace-pre-wrap">
            <Linkify text={selected.text || "No text."} />
          </div>
        </section>
        {translatedText && (
          <section>
            <h3 className="text-sm font-semibold">Translation</h3>
            <div className="mt-2 max-h-72 overflow-auto rounded-md bg-surface-container-lowest border border-primary/20 p-3 text-sm leading-6 whitespace-pre-wrap">
              <Linkify text={translatedText} />
            </div>
          </section>
        )}
        {selected.tags && <section><h3 className="text-sm font-semibold">Tags</h3><div className="mt-2 flex flex-wrap gap-2">{selected.tags.split(",").map(t => <span key={t} className="rounded bg-surface-container-high px-2 py-1 text-xs font-semibold">{t.trim()}</span>)}</div></section>}
        <ActionButtons b={selected} busy={busyId === selected.id} translating={isTranslating} onReprocess={onReprocess} onEdit={onEdit} onTranslate={onTranslate} />
      </div>
    </aside>
  );
}
