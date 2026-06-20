# Little Things

A pile of personal projects, experiments, tools, notes, and recovered source snapshots. Some things are useful as-is. Some are reference material. Some are just here because losing them twice would be stupid.

There is no repo-wide build. Start in the folder for the thing you care about.

## Where Things Are

| Folder | What it is for |
| --- | --- |
| `Amiga/` | Commodore Amiga tools, source archives, tutorials, emulator notes, model/fine-tuning work, and the GitHub Pages source for the public project index. Start with `Amiga/README.md`. |
| `Amiga/Tools/` | macOS and Amiga utilities, including release builds where they exist. |
| `Amiga/aMiLa/` | Amiga language/model work: source corpus notes, fine-tuning scripts, model output, and related docs. |
| `Amiga/Tutorials/` | Notes and walkthroughs from Amiga experiments. |
| `Web_Apps/xbook-console/` | XBook Console: local bookmark/knowledge triage app. Contains the Next.js web app, Prisma database schema, tests, build scripts, and Tauri desktop packaging. |
| `Web_Apps/Mouth_Chart_FDI/` | Dental notation/charting web app experiment. |
| `Hardware/` | Raspberry Pi, Flume, SensorTag, Sleepia, and robotics work. Expect project-specific setup. |
| `Animations/` | Animation experiments and media assets. |
| `Apple_Watch_Apps/` | Older Apple Watch experiments. |
| `docs/` | Shared notes, images, KB articles, and tutorial material. |
| `useful_scripts/` | Small scripts for media/file cleanup tasks. Read `useful_scripts/README.md` before running them on anything important. |

## Things To Know

- `Web_Apps/xbook-console/` tracks app code, migrations, tests, and desktop packaging. It should not track personal SQLite databases, credentials, or local app data.
- `Amiga/aMiLa/Dataset/` is intentionally ignored. Do not bring that subtree back just to satisfy an automated dependency PR.
- Imported source snapshots may have their own license, README style, build assumptions, and dependency age. Check inside the specific folder before running or publishing anything from it.
- Dependency updates should be made in the package path that actually exists in the repo. If a bot opens a PR against ignored or removed material, close it or recreate the fix in the right place.
- Large binaries, generated artifacts, model files, PDFs, audio, and video should use Git LFS when they need to be tracked.

## Git LFS

Use LFS for things that do not belong in normal Git blobs:

- audio/video: `*.mp3`, `*.wav`, `*.mp4`, `*.mov`
- large PDFs and archives
- model weights: `*.safetensors`, checkpoints, generated model files
- datasets or generated binaries that must be kept

When adding a new LFS pattern, commit both `.gitattributes` and the file pointer.

;mE
