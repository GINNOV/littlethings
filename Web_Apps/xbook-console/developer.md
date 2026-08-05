# XBook Console Developer Guide

This document is for developers who want to set up, build, or contribute to XBook Console. For general information about what the app does, how to use it, and the native desktop experience, see [README.md](README.md).

---

## Technical Stack

- Next.js 16 App Router
- React 19
- TypeScript
- Prisma 7
- SQLite through `better-sqlite3`
- Tailwind CSS 4
- OpenAI-compatible chat and embeddings API
- Vitest for unit tests
- Playwright for end-to-end tests

## Setup

Install dependencies:

```bash
npm install
```

Apply database migrations:

```bash
npx prisma migrate dev
```

After setup, run the app with the commands below and configure credentials at `/settings`.

## Run the App

Development:

```bash
npm run dev
```

Then open:

```text
http://localhost:3000
```

Production build:

```bash
npm run build
npm run start
```

Run on a different port:

```bash
npm run dev -- --port 3100
```

Playwright uses that same pattern and starts the app on `http://localhost:3100` during `npm run test:e2e`.

## Configuration

Settings are stored in the local database and can also fall back to environment variables.

Common environment variables:

```bash
DATABASE_URL="file:./dev.db"
OPENAI_BASE_URL="http://localhost:1234/v1"
OPENAI_API_KEY="lm-studio"
OPENAI_MODEL="your-model"
X_CLIENT_ID="..."
X_CLIENT_SECRET="..."
YT_CLIENT_ID="..."
YT_CLIENT_SECRET="..."
```

Legacy X bearer-token fields still exist in settings, but bookmark sync requires an OAuth user access token.

## OAuth Callback URLs

X:

```text
http://localhost:3000/api/x/oauth/callback
```

Suggested X scopes:

```text
tweet.read users.read bookmark.read offline.access
```

YouTube:

```text
http://localhost:3000/api/oauth/youtube/callback
```

## Local LLMs

The app uses the OpenAI SDK against an OpenAI-compatible endpoint. Typical local defaults:

- LM Studio: `http://localhost:1234/v1`
- Ollama: `http://localhost:11434/v1`
- vLLM: `http://localhost:8000/v1`

The configured model must be available at the selected endpoint before enrichment starts. The enrichment API runs a model availability check first and fails early if the model is not loaded.

## App Flow

1. Configure X, YouTube, and LLM settings in `/settings`.
2. Use the Dashboard to sync X or YouTube items.
3. Enrich pending items from the Dashboard, Library, or Folders workflows.
4. Review runs and failures in `/processing`.
5. Search, filter, edit, reprocess, and mark items read in `/bookmarks`.

## Data Model

The local SQLite database defaults to `dev.db`.

Important Prisma models:

- `Bookmark`: imported X posts and YouTube videos.
- `BookmarkFolder`: X folders and YouTube playlists.
- `Settings`: local credentials, API limits, model config, and UI preferences.
- `UsageMonth`: monthly import usage by source.
- `OperationRun`: sync and enrichment run summaries.
- `ProcessingEvent`: per-run and per-bookmark processing events.
- `LlmRequestLog`: prompt, response, usage, timing, and error records.

## Commands

```bash
npm run dev
npm run build
npm run start
npm run lint
npm run test
npm run test:coverage
npm run test:e2e
npm run test:crap
npx prisma migrate dev
```

Playwright starts its own dev server on `http://localhost:3100`.

## Desktop Application (Tauri)

XBook Console can be packaged as a standalone macOS desktop application using Tauri.

### Desktop Commands

To build the desktop application:
```bash
npm run build:desktop
npx tauri build
```
This will compile the Next.js production build, copy all backend assets (including Prisma migrations and the local Node.js binary), compile the Rust runner, and generate the final packaged `.app` bundle at `src-tauri/target/release/bundle/macos/xbook.app`.

### Under the Hood

- **Self-contained Server:** On startup, the desktop app spawns a hidden background Node.js server using the bundled node binary and a wrapper script (`start-server.js`).
- **OS Application Data:** The SQLite database is created and migrated automatically in the user's home directory (e.g. `~/.xbook/dev.db`) to prevent write failures inside the read-only application bundle.
- **Secure Auto-Updater:** The app checks for signed releases automatically on boot. Update payloads are signed and cryptographically verified using the public key configured in `tauri.conf.json`.
- **Default Browser OAuth:** OAuth logins launch in the default system browser to support existing sessions and prevent Google's embedded webview block, returning credentials back to the local app.

## Versioning and Releases

XBook Console versions are defined in:
1. `package.json` (`"version": "0.3.0"`)
2. `src-tauri/tauri.conf.json` (`"version": "0.3.0"`)
3. `src-tauri/Cargo.toml` (`version = "0.3.0"`)

User-facing history lives in [CHANGELOG.md](CHANGELOG.md) ([Keep a Changelog](https://keepachangelog.com/) style). Update the **Unreleased** section as you land work; fold it into a dated version heading when you cut a release.

Tauri does not auto-increment these versions during compilation. To manage versioning and updates:

### Bumping Versions
- **Manual Syncing:** You can configure `tauri.conf.json` to read the version dynamically from `package.json` by updating its version configuration to:
  ```json
  "version": "../package.json"
  ```
  This allows you to bump both frontend and Tauri package versions simultaneously using standard package manager tools, e.g., `npm version patch`.

- **Release Automation:** Use tools like `standard-version` or `release-it` to auto-bump configs, draft logs, and create git tags based on conventional commits.

### Building and Signing Releases (CI/CD)
When deploying a production version of the desktop application, you must sign the update package using your generated private key:
1. Configure `TAURI_SIGNING_PRIVATE_KEY` as a secret environment variable in your build pipeline.
2. Use the official `tauri-apps/tauri-action` GitHub Action to automate building, signing, and uploading macOS `.app` bundles directly to GitHub Releases.

## Troubleshooting

If the app starts but fails with a `better_sqlite3.node` `NODE_MODULE_VERSION` error, rebuild the native SQLite dependency for your current Node version:

```bash
npm rebuild better-sqlite3
```

This usually happens after switching or upgrading Node.

## Project Structure

```text
src/app              Next.js pages, layouts, components, and route handlers
src/app/api          Import, enrichment, settings, OAuth, and processing APIs
src/app/components   UI components
src/app/hooks        Client-side UI hooks
src/app/lib          Server-side page fetchers and UI helpers
src/lib              Database, source fetchers, LLM, processing, settings
prisma               Schema and migrations
tests/unit           Vitest tests
tests/e2e            Playwright tests
```
