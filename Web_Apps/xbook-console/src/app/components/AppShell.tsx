"use client";

import Link from "next/link";
import { usePathname, useSearchParams } from "next/navigation";
import { useState, useEffect } from "react";
import { XLogo, YouTubeLogo } from "./Icons";
import { useUpdater } from "@/app/hooks/useUpdater";

const navItems = [
  { href: "/", label: "Dashboard", match: (pathname: string) => pathname === "/" },
  {
    href: "/bookmarks?source=x",
    label: (
      <span className="flex items-center gap-2">
        <XLogo className="h-3 w-3" /> Library
      </span>
    ),
    match: (pathname: string, source: string | null) =>
      pathname === "/xbooks" || (pathname === "/bookmarks" && source !== "yt"),
  },
  {
    href: "/bookmarks?source=yt",
    label: (
      <span className="flex items-center gap-2">
        <YouTubeLogo className="h-3 w-4" /> Library
      </span>
    ),
    match: (pathname: string, source: string | null) =>
      pathname === "/ybooks" || (pathname === "/bookmarks" && source === "yt"),
  },
  { href: "/folders", label: "Folders", match: (pathname: string) => pathname === "/folders" },
  {
    href: "/processing",
    label: "Processing",
    match: (pathname: string) => pathname === "/processing",
  },
  { href: "/settings", label: "Settings", match: (pathname: string) => pathname === "/settings" },
  { href: "/docs", label: "Docs", match: (pathname: string) => pathname === "/docs" || pathname.startsWith("/docs/") },
];

export default function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const source = searchParams.get("source");
  const [open, setOpen] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);

  // Initialize auto-updater inside Tauri environment
  useUpdater();

  useEffect(() => {
    let mounted = true;
    let eventSource: EventSource | null = null;

    const checkStatus = async () => {
      try {
        const res = await fetch("/api/processing/active", { cache: "no-store" });
        if (res.ok) {
          const json = await res.json();
          if (mounted) setIsProcessing(Boolean(json.active));
        }
      } catch {
        // Silently ignore
      }
    };

    const connectSSE = () => {
      if (eventSource) return;
      eventSource = new EventSource("/api/processing/events");
      
      const update = () => {
        checkStatus();
      };

      eventSource.addEventListener("run_created", update);
      eventSource.addEventListener("run_updated", update);
      
      eventSource.onerror = () => {
        if (eventSource) {
          eventSource.close();
          eventSource = null;
        }
        setTimeout(connectSSE, 5000);
      };
    };

    checkStatus();
    connectSSE();

    // Still keep a slow fallback poll just in case (every 30s)
    const timer = setInterval(checkStatus, 30000);

    return () => {
      mounted = false;
      clearInterval(timer);
      if (eventSource) {
        eventSource.close();
      }
    };
  }, []);

  return (
    <div className="min-h-screen bg-surface text-on-surface">
      <header className="sticky top-0 z-40 flex h-14 items-center justify-between bg-surface px-4 md:hidden">
        <Link href="/" className="font-headline text-xl font-bold tracking-tight">
          XB👀k
        </Link>
        <button
          type="button"
          onClick={() => setOpen((value) => !value)}
          className="rounded-md bg-surface-container-high px-3 py-2 text-sm font-semibold"
          aria-expanded={open}
        >
          Menu
        </button>
      </header>

      {open ? (
        <nav className="fixed inset-x-0 top-14 z-40 border-t border-outline-ghost bg-surface p-3 md:hidden">
          <div className="grid gap-1">
            {navItems.map((item) => {
              const active = item.match(pathname, source);
              const isProcessingLink = typeof item.label === "string" && item.label === "Processing";

              return (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={() => setOpen(false)}
                  className={`rounded-md px-3 py-2 text-sm font-semibold transition ${
                    active
                      ? "bg-surface-container-high text-primary"
                      : "text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface"
                  } ${isProcessingLink && isProcessing ? "animate-blink-red" : ""}`}
                >
                  {item.label}
                </Link>
              );
            })}
          </div>
        </nav>
      ) : null}

      <aside className="fixed left-0 top-0 z-50 hidden h-full w-60 flex-col bg-surface-container px-4 py-6 md:flex">
        <div className="mb-8 px-2">
          <Link href="/" className="font-headline text-xl font-bold tracking-tight">
            XB👀k Console
          </Link>
          <p className="mt-1 text-xs font-medium text-on-surface-variant">
            Local-first research
          </p>
        </div>

        <nav className="flex flex-1 flex-col gap-1">
          {navItems.map((item) => {
            const active = item.match(pathname, source);
            const isProcessingLink = typeof item.label === "string" && item.label === "Processing";

            return (
              <Link
                key={item.href}
                href={item.href}
                className={`rounded-md px-3 py-2 text-sm font-semibold transition ${
                  active
                    ? "translate-x-1 bg-surface-container-high text-primary shadow-[inset_-4px_0_0_var(--primary)]"
                    : "text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface"
                } ${isProcessingLink && isProcessing ? "animate-blink-red" : ""}`}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>

        <div className="border-t border-outline-ghost pt-4 text-xs text-on-surface-variant">
          <p>Sync and enrichment audit trail</p>
        </div>
      </aside>

      <div className="md:pl-60">{children}</div>
    </div>
  );
}
