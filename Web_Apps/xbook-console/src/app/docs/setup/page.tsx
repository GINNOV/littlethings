import Link from "next/link";
import { DocsPageShell } from "../DocsPageShell";

export default function DocsSetupPage() {
  return (
    <DocsPageShell
      title="Development environment setup"
      description="Install dependencies, migrate SQLite, optionally seed env vars, then run the web app or tests."
    >
      <div className="space-y-8">
        <p className="text-on-surface-variant leading-relaxed">
          Short path to a working local stack. For Tauri packaging, ports, and contribution notes see{" "}
          <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs text-on-surface">developer.md</code>{" "}
          in the repo root.
        </p>

        <div className="rounded-2xl bg-white p-8 shadow-sm border border-outline-variant/30 space-y-6">
          <div className="space-y-6">
            <div className="flex gap-4">
              <div className="w-1 bg-primary rounded-full shrink-0" />
              <div className="space-y-2 flex-1">
                <p className="font-bold text-base text-primary">1. Install packages &amp; migrate schema</p>
                <p className="text-sm text-on-surface-variant leading-6">
                  Install dependencies and apply Prisma migrations for the local SQLite database:
                </p>
                <pre className="mt-2 overflow-x-auto rounded-lg bg-slate-950 p-3 text-xs text-slate-100 font-mono">
                  npm install{"\n"}
                  npx prisma migrate dev
                </pre>
              </div>
            </div>

            <div className="flex gap-4">
              <div className="w-1 bg-primary rounded-full shrink-0" />
              <div className="space-y-2 flex-1">
                <p className="font-bold text-base text-primary">2. Environment variables (optional fallbacks)</p>
                <p className="text-sm text-on-surface-variant leading-6">
                  Day-to-day config lives in{" "}
                  <Link href="/settings" className="text-primary hover:underline font-semibold">
                    Settings
                  </Link>{" "}
                  (SQLite). Env vars apply when those fields are empty. Create{" "}
                  <code className="rounded bg-surface-container-low px-1.5 py-0.5 text-xs text-on-surface">
                    .env.local
                  </code>{" "}
                  if useful:
                </p>
                <pre className="mt-2 overflow-x-auto rounded-lg bg-slate-950 p-3 text-xs text-slate-100 font-mono">
                  DATABASE_URL=&quot;file:./dev.db&quot;{"\n"}
                  OPENAI_BASE_URL=&quot;http://127.0.0.1:1234/v1&quot;{"\n"}
                  OPENAI_API_KEY=&quot;lm-studio&quot;{"\n"}
                  OPENAI_MODEL=&quot;your-chat-model&quot;{"\n"}
                  OPENAI_EMBEDDING_MODEL=&quot;nomic-embed-text&quot;{"\n"}
                  X_CLIENT_ID=&quot;your-x-client-id&quot;{"\n"}
                  X_CLIENT_SECRET=&quot;your-x-client-secret&quot;{"\n"}
                  YT_CLIENT_ID=&quot;your-youtube-client-id&quot;{"\n"}
                  YT_CLIENT_SECRET=&quot;your-youtube-client-secret&quot;{"\n"}
                  AGENT_API_TOKEN=&quot;optional-token-for-agent-api&quot;
                </pre>
              </div>
            </div>

            <div className="flex gap-4">
              <div className="w-1 bg-primary rounded-full shrink-0" />
              <div className="space-y-2 flex-1">
                <p className="font-bold text-base text-primary">3. Run, test, and package</p>
                <p className="text-sm text-on-surface-variant leading-6">
                  Start the web app, run unit tests, Playwright e2e (app on port 3100), or build the desktop bundle:
                </p>
                <pre className="mt-2 overflow-x-auto rounded-lg bg-slate-950 p-3 text-xs text-slate-100 font-mono">
                  npm run dev{"\n"}
                  npm run test{"\n"}
                  npm run test:e2e{"\n"}
                  npm run build:desktop
                </pre>
              </div>
            </div>
          </div>
        </div>

        <p className="text-sm text-on-surface-variant leading-6">
          Next:{" "}
          <Link href="/docs/agent-api" className="text-primary hover:underline font-semibold">
            Agent API
          </Link>{" "}
          for local automation (Hermes, scripts).
        </p>
      </div>
    </DocsPageShell>
  );
}
