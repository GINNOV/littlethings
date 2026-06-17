import { XLogo, YouTubeLogo } from "../Icons";
import { Bookmark } from "../../hooks/useBookmarksList";

type Props = { b: Bookmark; busy: boolean; translating: boolean; onReprocess: any; onEdit: any; onTranslate: any; };

export function ActionButtons({ b, busy, translating, onReprocess, onEdit, onTranslate }: Props) {
  const btn = "rounded-md bg-surface-container-high px-4 py-2 text-sm font-semibold text-on-surface disabled:opacity-60 transition-colors";
  return (
    <div className="grid gap-2">
      <a href={b.tweetUrl} target="_blank" rel="noreferrer" className="rounded-md bg-primary px-4 py-2 text-center text-sm font-semibold text-white flex items-center justify-center gap-2 hover:bg-primary-strong">
        {b.source === "yt" ? <YouTubeLogo className="h-3 w-4 fill-white" /> : <XLogo className="h-3 w-3" />} Open original
      </a>
      <button onClick={() => onReprocess(b.id)} disabled={busy} className={btn}>{busy ? "Reprocessing..." : "Reprocess with LLM"}</button>
      <button onClick={() => onEdit(b)} className={btn}>Edit enrichment</button>
      <button onClick={() => onTranslate(b.id)} disabled={translating || busy} className={btn}>{translating ? "Translating..." : "Translate"}</button>
    </div>
  );
}
