"use client";

import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { XLogo, YouTubeLogo } from "../Icons";

type Props = {
  categories: (string | null)[];
  folders: { id: string; name: string | null }[];
  q: string; source: string; category: string; status: string; video: boolean; semantic: boolean; folderId: string;
};

export function FilterControls({ categories, folders, q, source, category, status, video, semantic, folderId }: Props) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const sel = "rounded-md border-0 bg-surface-variant px-4 py-2 text-sm focus:ring-1 focus:ring-primary";
  const hasFilter = q || category || folderId || source || status || video || semantic;

  const updateSource = (newSource: string) => {
    const params = new URLSearchParams(searchParams.toString());
    if (newSource === source || !newSource) {
      params.delete("source");
    } else {
      params.set("source", newSource);
    }
    router.push(`/bookmarks?${params.toString()}`);
  };

  return (
    <section className="rounded-lg bg-surface-container-lowest p-6 shadow-sm border border-outline-variant/30">
      <form method="GET" action="/bookmarks" className="flex flex-wrap items-center gap-4">
        <input type="text" name="q" defaultValue={q} placeholder="Search bookmarks..." className="min-w-[320px] flex-1 rounded-md border-0 bg-surface-variant px-4 py-2 text-sm focus:ring-1 focus:ring-primary" />
        
        <div className="flex items-center gap-1 rounded-lg bg-surface-variant p-1 h-9">
          <button
            type="button"
            onClick={() => updateSource("x")}
            className={`flex h-7 w-10 items-center justify-center rounded transition ${
              source === "x" ? "bg-surface-container-lowest text-on-surface shadow-sm" : "text-on-surface-variant hover:text-on-surface"
            }`}
            title="X Bookmarks"
          >
            <XLogo className="h-3.5 w-3.5" />
          </button>
          <button
            type="button"
            onClick={() => updateSource("yt")}
            className={`flex h-7 w-10 items-center justify-center rounded transition ${
              source === "yt" ? "bg-surface-container-lowest text-on-surface shadow-sm" : "text-on-surface-variant hover:text-on-surface"
            }`}
            title="YouTube Bookmarks"
          >
            <YouTubeLogo className="h-3.5 w-4.5" />
          </button>
          <input type="hidden" name="source" value={source} />
        </div>

        <select name="category" defaultValue={category} className={sel}><option value="">All categories</option>{categories.map(c => <option key={c} value={c!}>{c}</option>)}</select>
        <select name="status" defaultValue={status} className={sel}><option value="">All status</option><option value="pending">Pending</option><option value="summarized">Summarized</option></select>
        <select name="video" defaultValue={video ? "true" : ""} className={sel}><option value="">All content</option><option value="true">Videos only</option></select>
        <label className="flex items-center gap-2 rounded-md bg-surface-variant px-3 py-2 text-sm cursor-pointer hover:bg-surface-variant/80 transition-colors">
          <input type="checkbox" name="semantic" value="true" defaultChecked={semantic} className="h-4 w-4 rounded border-outline bg-surface focus:ring-primary" />
          <span className="font-medium">Semantic Search</span><span className="text-[10px] bg-primary/10 text-primary px-1 rounded font-bold uppercase tracking-wider">AI</span>
        </label>
        <select name="folderId" defaultValue={folderId} className={sel}><option value="">All folders</option>{folders.map(f => <option key={f.id} value={f.id}>{f.name || f.id}</option>)}</select>
        <button type="submit" className="rounded-md bg-black px-6 py-2 text-sm font-semibold text-white transition hover:bg-black/80">Search</button>
        {hasFilter && <Link href="/bookmarks" className="text-sm font-semibold text-on-surface-variant hover:text-on-surface">Clear</Link>}
      </form>
    </section>
  );
}
