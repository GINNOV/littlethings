"use client";

import Link from "next/link";
import { XLogo, YouTubeLogo } from "../Icons";

type Props = {
  tab: "x" | "yt";
};

export function DashboardHeader({ tab }: Props) {
  return (
    <header className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
      <div>
        <h1 className="font-headline text-5xl font-semibold tracking-tight">
          Dashboard
        </h1>
        <p className="mt-2 text-sm text-on-surface-variant">
          Overview and system health.
        </p>
      </div>
      <section className="flex w-64 items-center gap-1 rounded-lg bg-surface-container-high p-1">
        <Link
          href="/?tab=x"
          className={`flex flex-1 items-center justify-center rounded-md py-2 transition ${
            tab === "x"
              ? "bg-surface-container-lowest text-on-surface shadow-sm"
              : "text-on-surface-variant hover:text-on-surface"
          }`}
          title="X"
        >
          <XLogo className="h-4 w-4" />
        </Link>
        <Link
          href="/?tab=yt"
          className={`flex flex-1 items-center justify-center rounded-md py-2 transition ${
            tab === "yt"
              ? "bg-surface-container-lowest text-on-surface shadow-sm"
              : "text-on-surface-variant hover:text-on-surface"
          }`}
          title="YouTube"
        >
          <YouTubeLogo className="h-4 w-6" />
        </Link>
      </section>
    </header>
  );
}
