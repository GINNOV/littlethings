# Repository Guidelines

## Project Structure & Module Organization
This project is a Next.js (App Router) dashboard for Flume water data.
- `src/app/`: routes and API handlers (`api/flume/auth`, `devices`, `usage`).
- `src/components/`: shared UI and chart components (`Shell`, `Sidebar`, `UsageChart`).
- `src/lib/`: integration and utility logic (Flume API client, analytics helpers).
- `public/`: static assets.
- `AI/`: planning notes and product context.
- Root config: `next.config.ts`, `tsconfig.json`, `eslint.config.mjs`, `.env.example`.

Use the `@/*` import alias (configured in `tsconfig.json`) for code under `src/`.

## Build, Test, and Development Commands
- `npm install`: install dependencies.
- `npm run dev`: start local development server at `http://localhost:3000`.
- `npm run build`: production build check.
- `npm run start`: run the production build locally.
- `npm run lint`: run ESLint (Next.js + TypeScript rules).

Before opening a PR, run at least `npm run lint` and `npm run build`.

## Coding Style & Naming Conventions
- Language: TypeScript with `strict` mode enabled.
- Indentation: 2 spaces; keep lines focused and readable.
- Components/files: `PascalCase` for React components (for example, `UsageChart.tsx`).
- Variables/functions: `camelCase`.
- Route folders in `src/app`: lowercase (`history`, `insights`, `settings`).
- Prefer small, single-purpose modules; keep API-only logic server-side.

Use ESLint as the source of truth for style/lint issues.

## Testing Guidelines
There is currently no dedicated automated test suite in this repository. For now:
- Run `npm run lint` and `npm run build` on every change.
- Manually verify key flows: dashboard load, history range changes, insights, and settings.

If adding tests, place them near code as `*.test.ts` / `*.test.tsx` and prioritize API route behavior and data transformation logic.

## Commit & Pull Request Guidelines
Current history favors short, imperative commit messages (for example, `add hourly usage aggregation`).
- Keep subject lines concise and action-oriented.
- Group related changes in one commit; avoid mixing refactors and feature work.

PRs should include:
- Purpose and scope.
- Any env/config changes (`.env.local` keys, API assumptions).
- Verification steps run (`lint`, `build`, manual checks).
- Screenshots for UI changes (dashboard/history/insights/settings).

## Security & Configuration Tips
- Never commit real Flume credentials; use `.env.local` (see `.env.example`).
- Keep `FLUME_CLIENT_SECRET`, username, and password server-only.
- Do not expose secrets in client components or browser network payloads.
