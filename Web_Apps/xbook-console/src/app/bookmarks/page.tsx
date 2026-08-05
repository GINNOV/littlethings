import Link from "next/link";
import BookmarksList from "@/app/components/BookmarksList";
import { FilterControls } from "@/app/components/bookmarks/FilterControls";
import { PaginationControls } from "@/app/components/bookmarks/PaginationControls";
import { getBookmarksPageData, buildPageHref } from "@/app/lib/bookmarks-fetcher";

export const dynamic = "force-dynamic";
const PAGE_SIZE = 100;

export default async function BookmarksPage({ searchParams }: { searchParams?: Promise<Record<string, string | string[] | undefined>> }) {
  const p = await searchParams;
  const d = await getBookmarksPageData(p, PAGE_SIZE);
  const from = d.data.total === 0 ? 0 : (d.currentPage - 1) * PAGE_SIZE + 1;
  const to = (d.currentPage - 1) * PAGE_SIZE + d.data.bookmarks.length;
  const href = buildPageHref(p);

  return (
    <main className="min-h-screen bg-surface-container-low px-4 py-6 lg:px-8 lg:py-8">
      <div className="mx-auto flex max-w-[1500px] flex-col gap-8">
        <header className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <h1 className="font-headline text-5xl font-semibold tracking-tight">
              {d.src === "yt" ? "YouTube Library" : d.src === "x" ? "X Library" : "Library"}
            </h1>
            <p className="mt-2 text-sm text-on-surface-variant">
              Browse and search your knowledge base
              {d.filters.counts.total > 0
                ? ` · ${d.filters.counts.total.toLocaleString()} items`
                : ""}
              .
            </p>
          </div>
          <Link
            href="/docs/library"
            className="text-sm font-semibold text-on-surface-variant hover:text-primary"
          >
            Library reference →
          </Link>
        </header>
        <FilterControls
          categories={d.filters.categories}
          folders={d.filters.folders}
          counts={d.filters.counts}
          q={d.q}
          source={d.src}
          category={d.cat}
          status={d.st}
          video={d.vid}
          semantic={d.sem}
          folderId={d.fid}
        />
        <BookmarksList initial={d.data.bookmarks} />
        <PaginationControls from={from} to={to} total={d.data.total} currentPage={d.currentPage} totalPages={d.totalPages} pageHref={href} />
      </div>
    </main>
  );
}
