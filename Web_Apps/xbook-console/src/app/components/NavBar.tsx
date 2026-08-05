"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

export default function NavBar() {
  const pathname = usePathname();

  const linkClass = (href: string) => {
    const isActive =
      (href === "/bookmarks" && (pathname === "/bookmarks" || pathname === "/xbooks" || pathname === "/ybooks")) ||
      pathname === href;
    return `transition ${
      isActive
        ? "text-emerald-800 underline underline-offset-8"
        : "text-slate-700 hover:text-emerald-800"
    }`;
  };

  return (
    <nav className="sticky top-0 z-30 border-b border-black/5 bg-[#f7f3ea]/90 backdrop-blur">
      <div className="mx-auto flex w-full max-w-6xl items-center justify-between px-6 py-4">
        <Link
          href="/"
          className="text-sm font-semibold uppercase tracking-[0.3em] text-emerald-700"
        >
          BOOKMARK ATLAS
        </Link>
        <div className="flex items-center gap-4 text-sm font-medium">
          <Link href="/" className={linkClass("/")}>Dashboard</Link>
          <Link href="/bookmarks" className={linkClass("/bookmarks")}>Library</Link>
          <Link href="/settings" className={linkClass("/settings")}>Settings</Link>
          <Link href="/docs" className={linkClass("/docs")}>Docs</Link>
        </div>
      </div>
    </nav>
  );
}
