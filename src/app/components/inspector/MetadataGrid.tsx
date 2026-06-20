import { Bookmark } from "../../hooks/useBookmarksList";

export function MetadataGrid({ b }: { b: Bookmark }) {
  const cell = (l: string, v: string, c?: string) => (
    <div className={`rounded-md p-3 ${c || "bg-surface-container-lowest"}`}>
      <p className="text-xs uppercase text-on-surface-variant">{l}</p>
      <p className={`truncate font-semibold ${c ? "text-emerald-900" : ""}`}>{v}</p>
    </div>
  );
  
  const author = b.authorUsername ? (b.source === "x" ? `@${b.authorUsername}` : b.authorUsername) : "Unknown";
  const state = (b.readAt ? "Read" : "Unread") + (b.editedAt ? " · Edited" : "");

  return (
    <div className="grid grid-cols-2 gap-3 text-sm">
      {cell(b.source === "yt" ? "Channel" : "Author", author)}
      {cell("State", state, b.readAt ? "bg-emerald-100/80" : undefined)}
      {cell("Posted", b.createdAt ? new Date(b.createdAt).toLocaleString() : "-")}
      {cell("Imported", b.importedAt ? new Date(b.importedAt).toLocaleString() : "-")}
    </div>
  );
}
