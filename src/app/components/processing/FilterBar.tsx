"use client";

import Link from "next/link";
import { getFilterUrl } from "@/app/lib/processing-utils";

type Props = {
  status: string; source: string; errorsOnly: boolean;
  currentParams: any;
};

export function FilterBar({ status, source, errorsOnly, currentParams }: Props) {
  const btn = (active: boolean) => `rounded-md px-3 py-1.5 text-xs font-semibold ${active ? "bg-primary text-white" : "bg-surface-container-high"}`;
  const sBtn = (active: boolean) => `rounded-md px-3 py-1.5 text-xs font-semibold ${active ? "bg-on-surface text-surface" : "bg-surface-container-high"}`;

  return (
    <section className="flex flex-wrap items-center justify-between gap-4 border-b border-outline-variant pb-4">
      <div className="flex flex-wrap items-center gap-2">
        <span className="mr-2 text-xs font-semibold uppercase text-on-surface-variant">Status:</span>
        <Link href={getFilterUrl(currentParams, { status: null, errorsOnly: false })} className={btn(!status && !errorsOnly)}>All</Link>
        <Link href={getFilterUrl(currentParams, { status: "running", errorsOnly: false })} className={btn(status === "running")}>Running</Link>
        <Link href={getFilterUrl(currentParams, { status: "completed", errorsOnly: false })} className={btn(status === "completed")}>Completed</Link>
        <Link href={getFilterUrl(currentParams, { status: null, errorsOnly: true })} className={`rounded-md px-3 py-1.5 text-xs font-semibold ${errorsOnly ? "bg-error text-white" : "bg-surface-container-high"}`}>Errors</Link>
      </div>
      <div className="flex flex-wrap items-center gap-2">
        <span className="mr-2 text-xs font-semibold uppercase text-on-surface-variant">Source:</span>
        <Link href={getFilterUrl(currentParams, { source: null })} className={sBtn(!source)}>Both</Link>
        <Link href={getFilterUrl(currentParams, { source: "x" })} className={sBtn(source === "x")}>X</Link>
        <Link href={getFilterUrl(currentParams, { source: "yt" })} className={sBtn(source === "yt")}>YouTube</Link>
      </div>
    </section>
  );
}
