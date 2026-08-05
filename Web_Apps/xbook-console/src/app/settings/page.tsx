import { headers } from "next/headers";
import SettingsForm from "@/app/components/SettingsForm";
import type { Settings } from "@/app/components/settings/types";
import { getUsageMonth } from "@/lib/settings";
import { getSettingsPageData, DEFAULT_PROMPT } from "@/app/lib/settings-fetcher";

export const dynamic = "force-dynamic";

export default async function SettingsPage() {
  const { dia, init } = await getSettingsPageData();
  const usage = await getUsageMonth();
  const headerList = await headers();
  const host = headerList.get("host") ?? "localhost:3000";
  const protocol = headerList.get("x-forwarded-proto") ?? "http";
  const agentApiBaseUrl = `${protocol}://${host}/api/agent`;

  return (
    <main className="flex min-h-screen flex-col gap-8 bg-surface px-5 py-6 text-on-surface md:px-8">
      <header className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <p className="text-sm font-semibold uppercase text-primary">Configuration</p>
          <h1 className="mt-2 font-headline text-4xl font-semibold">Settings</h1>
          <p className="mt-2 max-w-2xl text-sm leading-6 text-on-surface-variant">
            Connect accounts, set chat and embedding models, then tune limits and data. Use the tabs to focus on one area at a time.
          </p>
        </div>
      </header>
      <section className="rounded-lg bg-surface-container-low p-4 md:p-6">
        <SettingsForm
          initial={init as Settings}
          usedThisMonth={usage.usedBookmarks}
          defaultPrompt={DEFAULT_PROMPT}
          agentApiBaseUrl={agentApiBaseUrl}
          agentApiTokenConfigured={Boolean(process.env.AGENT_API_TOKEN)}
          xDiagnostics={dia}
        />
      </section>
    </main>
  );
}
