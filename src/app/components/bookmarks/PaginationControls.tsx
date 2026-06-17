import Link from "next/link";

type Props = {
  from: number; to: number; total: number; currentPage: number; totalPages: number;
  pageHref: (n: number) => string;
};

export function PaginationControls({ from, to, total, currentPage, totalPages, pageHref }: Props) {
  const btn = "rounded-md bg-surface-container-high px-4 py-2 text-sm font-semibold text-on-surface transition hover:bg-surface-container-highest";
  const dis = "cursor-not-allowed rounded-md bg-surface-container-high px-4 py-2 text-sm font-semibold text-on-surface-variant";

  return (
    <div className="flex items-center justify-between border-t border-outline-ghost pt-6">
      <p className="text-sm text-on-surface-variant font-medium">Showing <span className="text-on-surface">{from}</span> to <span className="text-on-surface">{to}</span> of <span className="text-on-surface">{total}</span> bookmarks</p>
      <div className="flex items-center gap-2">
        {currentPage > 1 ? <Link href={pageHref(currentPage - 1)} className={btn}>Previous</Link> : <span className={dis}>Previous</span>}
        {currentPage < totalPages ? <Link href={pageHref(currentPage + 1)} className={btn}>Next</Link> : <span className={dis}>Next</span>}
      </div>
    </div>
  );
}
