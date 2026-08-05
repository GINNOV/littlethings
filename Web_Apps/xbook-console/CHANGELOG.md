# Changelog

All notable changes to **XBook Console** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project aims to follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Dedicated **embedding model** and **embedding base URL** settings so chat (e.g. vLLM) and embeddings (e.g. Ollama `nomic-embed-text`) can run on different hosts.
- Dashboard **index health** panel: indexed vs missing embeddings, coverage bar, and **Sync embeddings** action.
- One-click **Process inbox** flow: import new items, enrich pending, then backfill embeddings.
- Advanced dashboard actions (sync-only, enrich pending, batch, force reprocess) behind a collapsible section.
- In-app docs coverage for the process-inbox and embedding-index workflows.
- Prisma fields / migrations: `llmEmbeddingModel`, `llmEmbeddingBaseUrl`.

### Fixed

- **Sync embeddings** failed with HTTP 404 when the chat LLM server had no `/v1/embeddings` endpoint. Embedding generation now uses the embedding model (and optional embedding base URL) instead of the chat model URL.
- Clearer embedding error messages when the embeddings endpoint or model is misconfigured.
- Embedding sync query only selects bookmarks with a non-empty summary.
- Index health **missing** count no longer disagreed with sync progress: both use the same “needs embedding” rule, dashboard sync is **tab-scoped**, and progress shows `N of T · remaining` while live missing/indexed counters update during the run.
- **X sync burned API spend re-fetching immutable tweets**: delta sync no longer re-hydrates the whole library (was “0 new, refreshed 368”). With a baseline it only walks new global bookmarks, skips full folder re-scans, and only advances `lastBookmarkId` from the global feed (folder tweets no longer corrupt the baseline).

### Changed

- Ollama and vLLM presets seed sensible embedding defaults (Ollama-compatible embeddings host + `nomic-embed-text` when unset).
- Embedding generation no longer falls back to the chat model id (chat models are usually unsupported by embeddings APIs).
- Settings → **Sync all missing embeddings** remains global; the dashboard button only indexes the active tab (X or YouTube).

## [0.3.0] - 2026-06-23

### Added

- Bulk reprocessing of already-enriched bookmarks.
- Desktop **window state** persistence (size/position) via Tauri.
- Database **backup / restore** controls in settings.
- Release packaging and auto-updater pointed at the standalone [GINNOV/xbook](https://github.com/GINNOV/xbook) repository.

### Changed

- Desktop standalone bundle skips unnecessary directories for smaller packages.
- Version aligned across `package.json`, Tauri config, and Cargo crate (`0.3.0`).

### Fixed

- Dependency and Dependabot security cleanups (including `undici` bumps).

## [0.2.0] - 2026-06-22

### Added

- First tagged desktop-oriented release line for XBook Console.
- Versioning and release-automation notes for maintainers.

### Fixed

- Desktop startup reliability and packaging issues after Tauri restore.
- Unit / packaging test stability around the 0.2 release cut.

## [0.1.0] - 2026-06-17

Initial product foundation (pre-0.2 packaging polish).

### Added

- Local **SQLite** knowledge base for X (Twitter) and YouTube bookmarks.
- OAuth import / delta sync for X bookmarks and YouTube playlists/folders.
- Local or remote **LLM enrichment**: summaries, categories, tags.
- **Vector embeddings** field and semantic search over enriched content.
- Processing runs, events, and LLM request logging.
- Settings for LLM providers (LM Studio, Ollama, vLLM, OpenAI-compatible), concurrency, context/response limits, thinking mode, sounds, and monthly usage caps.
- Next.js App Router UI: dashboard, bookmarks lists, folders, processing monitor, settings, docs.
- Tauri desktop shell with bundled Node server and Prisma migrations.

---

## Release tags

| Version | Git tag       |
| ------- | ------------- |
| 0.3.0   | `xbook-v0.3.0` |
| 0.2.0   | `xbook-v0.2.0` |

## How to update this file

1. Under **[Unreleased]**, add entries as you merge work (`Added` / `Changed` / `Fixed` / `Removed` / `Security`).
2. When cutting a release, rename `[Unreleased]` to `[X.Y.Z] - YYYY-MM-DD`, bump versions in `package.json`, `src-tauri/tauri.conf.json`, and `src-tauri/Cargo.toml`, and open a fresh empty `[Unreleased]` section at the top.
3. Prefer short, user-facing bullets over internal commit lists.
