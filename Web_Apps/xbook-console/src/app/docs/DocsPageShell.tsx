import type { ReactNode } from "react";
import Link from "next/link";

type Props = {
  title: string;
  description?: string;
  children: ReactNode;
};

export function DocsPageShell({ title, description, children }: Props) {
  return (
    <main className="min-h-screen bg-surface-container-low px-4 py-12 lg:px-8 lg:py-16">
      <div className="mx-auto max-w-4xl space-y-12">
        <header className="space-y-4">
          <Link
            href="/docs"
            className="inline-flex text-sm font-semibold text-primary hover:underline"
          >
            ← Back to Docs
          </Link>
          <h1 className="font-headline text-5xl font-semibold tracking-tight text-primary">
            {title}
          </h1>
          {description ? (
            <p className="max-w-2xl text-lg text-on-surface-variant leading-relaxed">
              {description}
            </p>
          ) : null}
        </header>

        {children}

        <footer className="pt-8 border-t border-outline-ghost flex flex-col sm:flex-row items-center justify-between gap-4">
          <Link href="/docs" className="text-sm font-semibold text-primary hover:underline">
            ← Back to Docs
          </Link>
          <Link
            href="/"
            className="rounded-full bg-black px-8 py-3 text-sm font-bold text-white shadow-xl transition hover:scale-105 active:scale-95"
          >
            Back to Dashboard
          </Link>
        </footer>
      </div>
    </main>
  );
}
