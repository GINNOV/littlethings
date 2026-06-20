import { XLogo, YouTubeLogo } from "../Icons";

type Props = { source: string; title: string | null; category?: string | null; folderName?: string | null; onClose: () => void; };

export function InspectorHeader({ source, title, category, folderName, onClose }: Props) {
  return (
    <>
      <button type="button" onClick={onClose} className="absolute right-4 top-4 rounded-full p-1 text-on-surface-variant hover:bg-surface-container-high transition-colors"><svg viewBox="0 0 20 20" fill="currentColor" className="h-5 w-5"><path d="M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z" /></svg></button>
      <div>
        <p className="text-xs font-semibold uppercase text-primary">Entry details</p>
        <h2 className="mt-1 font-headline text-2xl font-semibold flex items-center gap-2">
          {source === "yt" ? <YouTubeLogo className="h-4 w-5" /> : <XLogo className="h-4 w-4" />}
          {title || (source === "yt" ? "Video" : "Bookmark")}
        </h2>
        <p className="mt-2 text-sm text-on-surface-variant">{category || "Uncategorized"}{folderName ? ` · ${folderName}` : ""}</p>
      </div>
    </>
  );
}
