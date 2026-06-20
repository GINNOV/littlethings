import Link from "next/link";
import { XLogo, YouTubeLogo } from "@/app/components/Icons";

type RecentBookmark = {
  id: string;
  source: string;
  tweetUrl: string;
  text: string | null;
  summary: string | null;
  category: string | null;
  authorUsername: string | null;
  importedAt: Date | string | null;
  rawJson: string | null;
  folder: { name: string | null } | null;
};

type Props = {
  tab: "x" | "yt";
  recent: RecentBookmark[];
  getYouTubeTitle: (rawJson: string | null, text: string | null) => string | null;
  getYouTubeFolder: (rawJson: string | null, folderName: string | null) => string | null;
  formatDateShort: (date: Date | string | null) => string;
};

function getImportOrigin(bookmark: RecentBookmark) {
  if (bookmark.source === "x" || bookmark.source === "yt") {
    return {
      label: "Remote",
      detail: bookmark.source === "x" ? "X sync" : "YouTube sync",
      className: "bg-emerald-50 text-emerald-700 border-emerald-100",
    };
  }

  return {
    label: "Local",
    detail: bookmark.source === "agent" ? "Agent API" : bookmark.source,
    className: "bg-slate-100 text-slate-700 border-slate-200",
  };
}

export function RecentImports({
  tab,
  recent,
  getYouTubeTitle,
  getYouTubeFolder,
  formatDateShort,
}: Props) {
  return (
    <section className="rounded-lg bg-surface-container-lowest p-5 shadow-sm border border-outline-variant/30">
      <div className="mb-4 flex items-center justify-between">
        <div className="flex items-center gap-6">
          <h2 className="text-base font-semibold">Recent imports</h2>
          <div className="flex w-32 items-center gap-1 rounded-md bg-surface-container-high p-1">
            <Link
              href="/?tab=x"
              className={`flex flex-1 items-center justify-center rounded py-1 transition ${
                tab === "x"
                  ? "bg-surface-container-lowest text-on-surface shadow-sm"
                  : "text-on-surface-variant hover:text-on-surface"
              }`}
              title="X"
            >
              <XLogo className="h-3 w-3" />
            </Link>
            <Link
              href="/?tab=yt"
              className={`flex flex-1 items-center justify-center rounded py-1 transition ${
                tab === "yt"
                  ? "bg-surface-container-lowest text-on-surface shadow-sm"
                  : "text-on-surface-variant hover:text-on-surface"
              }`}
              title="YouTube"
            >
              <YouTubeLogo className="h-3 w-4" />
            </Link>
          </div>
        </div>
        <Link href={`/bookmarks?source=${tab}`} className="text-sm font-semibold text-primary">
          Open library
        </Link>
      </div>
      <div className="overflow-hidden rounded-lg bg-surface border border-outline-variant/30">
        <div className="grid grid-cols-[0.7fr_1.2fr_0.8fr_0.7fr_0.8fr_0.5fr] bg-surface-container px-4 py-2 text-[10px] font-bold uppercase tracking-wider text-on-surface-variant">
          <span>Category</span>
          <span>Entry</span>
          <span>Context</span>
          <span>Origin</span>
          <span>Date</span>
          <span className="text-right">Action</span>
        </div>
        {recent.slice(0, 8).map((bookmark) => {
          const origin = getImportOrigin(bookmark);
          const youtubeTitle =
            bookmark.source === "yt"
              ? getYouTubeTitle(bookmark.rawJson, bookmark.text)
              : null;
          const folderName =
            bookmark.source === "yt"
              ? getYouTubeFolder(bookmark.rawJson, bookmark.folder?.name ?? null)
              : bookmark.folder?.name ?? null;
          return (
            <div
              key={bookmark.id}
              className="grid grid-cols-[0.7fr_1.2fr_0.8fr_0.7fr_0.8fr_0.5fr] px-4 py-3 text-sm hover:bg-surface-container-low transition-colors items-center border-t border-outline-variant/20 first:border-t-0"
            >
              <span className="text-xs font-semibold">{bookmark.category ?? "Uncategorized"}</span>
              <span className="truncate font-medium pr-4">
                {youtubeTitle ?? bookmark.summary ?? bookmark.text ?? "Untitled"}
              </span>
              <span className="truncate text-on-surface-variant text-xs">
                {bookmark.source === "x"
                  ? bookmark.authorUsername
                    ? `@${bookmark.authorUsername}`
                    : "Unknown"
                  : bookmark.source === "yt"
                    ? folderName ?? "No playlist"
                    : folderName ?? origin.detail}
              </span>
              <span className="flex min-w-0 flex-col items-start gap-1">
                <span className={`rounded-full border px-2 py-0.5 text-[10px] font-bold uppercase ${origin.className}`}>
                  {origin.label}
                </span>
                <span className="max-w-full truncate text-[10px] text-on-surface-variant">
                  {origin.detail}
                </span>
              </span>
              <span className="text-xs text-on-surface-variant">
                {formatDateShort(bookmark.importedAt)}
              </span>
              <a
                href={bookmark.tweetUrl}
                target="_blank"
                rel="noreferrer"
                className="text-right text-xs font-bold uppercase text-primary hover:underline"
              >
                Open
              </a>
            </div>
          );
        })}
      </div>
    </section>
  );
}
