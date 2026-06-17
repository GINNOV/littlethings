# Repository Guidelines

## Project Structure & Module Organization
- `src/app`: Next.js App Router pages, layouts, and API routes.
- `src/app/api`: Server endpoints (e.g., `/api/import`, `/api/enrich`).
- `src/lib`: Server-side helpers (X API fetcher, LLM client, DB access).
- `prisma/`: Prisma schema and migrations; SQLite database is `dev.db` in repo root.
- `public/`: Static assets.

## Build, Test, and Development Commands
- `npm run dev`: Start the local dev server.
- `npm run build`: Build the production bundle.
- `npm run start`: Run the production server (after build).
- `npm run lint`: Run ESLint.
- `npx prisma migrate dev`: Apply schema changes to the local SQLite DB.

## Coding Style & Naming Conventions
- Language: TypeScript with Next.js App Router.
- Indentation: 2 spaces; use double quotes in TS/TSX (matches existing code).
- File naming: `PascalCase` for components, `camelCase` for utilities.
- Linting: ESLint via `eslint-config-next`.

## Testing Guidelines
- No automated tests are configured yet. If you add tests, place them near the feature or in a `__tests__` folder and document the runner and command in this file.

## Commit & Pull Request Guidelines
- Commit messages in history are short, imperative sentences (e.g., "added hash system"). Follow that pattern unless you introduce a formal convention.
- PRs should include a clear summary, steps to validate, and screenshots for UI changes.

## Security & Configuration Tips
- Store secrets in `.env.local` (see `.env.local.example`).
- Required: `X_BEARER_TOKEN`, `X_USER_ID`, `OPENAI_MODEL`.
- LM Studio default endpoint is `http://localhost:1234/v1`.
- Ollama default OpenAI-compatible endpoint is `http://localhost:11434/v1`.
