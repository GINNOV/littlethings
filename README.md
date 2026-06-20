# Little Things

This is a personal archive of experiments, tools, source snapshots, hardware projects, web apps, and notes across a few different domains. Treat it like a working garage: some folders are polished enough to use, some are research logs, and some are preserved because they are useful context.

## Start Here

| Folder | What is in it | Notes |
| --- | --- | --- |
| `Amiga/` | Commodore Amiga tools, tutorials, source archives, model/fine-tuning work, and docs. | The biggest active area. See `Amiga/README.md`. The old `Amiga/aMiLa/Dataset/` subtree is intentionally not tracked here. |
| `Web_Apps/xbook-console/` | XBook Console, a local-first bookmark and knowledge triage app. | Active product work. Includes the Next.js web app, Prisma schema, tests, and Tauri desktop packaging. |
| `Web_Apps/Mouth_Chart_FDI/` | Dental notation/charting web experiment. | Older standalone web app. |
| `Hardware/` | Raspberry Pi, SensorTag, Flume, Sleepia, and robotics projects. | Mixed age and polish; check each project README first. |
| `Animations/` | Animation experiments and media assets. | Large audio/video files should use Git LFS. |
| `Apple_Watch_Apps/` | Small Apple Watch experiments. | Older Xcode/watchOS projects. |
| `useful_scripts/` | Small shell scripts for media and file organization tasks. | See the script README before running them on important files. |
| `docs/` | Notes and reference material used by other projects. | Mostly supporting documentation. |

## Current Active Work

- **XBook Console** lives in `Web_Apps/xbook-console/`. It is the current local-first web and desktop app work. The repo tracks source, migrations, packaging scripts, and tests; it does not track your personal SQLite database or local credentials.
- **Amiga tooling and model work** lives under `Amiga/`. The public-facing project index is published through GitHub Pages at <https://ginnov.github.io/littlethings/>.
- **Dependency/security updates** should be applied only to active package paths. Do not resurrect ignored historical dataset folders just to satisfy automated dependency PRs.

## Repository Notes

- This repo intentionally contains a mix of original work, historical notes, imported source archives, and external/vendor material.
- The imported material is useful context, but it may carry its own README style, license, build assumptions, and dependency history.
- For large binaries, models, PDFs, audio, and video, use Git LFS instead of regular Git tracking.
- Some older projects have vulnerable or outdated dependencies because they are preserved as historical code. Check the local README and package files before running them.
- The `Amiga/aMiLa/Dataset/` subtree is ignored on purpose. Keep dataset-scale generated or imported corpora out of normal Git history unless there is a deliberate reason to reintroduce a small, curated subset.

## Git LFS

Use LFS for files that are large, binary, or likely to change poorly in normal Git history:

- `*.mp3`, `*.wav`, `*.mp4`, `*.mov`
- `*.pdf` when the file is large
- `*.safetensors`, model weights, datasets, archives, and generated binaries

After adding a new LFS pattern, commit both `.gitattributes` and the file pointer.

## Project Status

This is not a single product with one build command. It is a collection. The best entry point is the README nearest to the folder you want to use.

Reach out if you have questions or cool things to share.

;mE
