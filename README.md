# One man's junk is another man's treasure

This is a personal archive of experiments, tools, source snapshots, hardware projects, and notes across a few different domains. Treat it like a garage sale: some folders are polished enough to use, some are research logs, and some are kept here because they were useful to preserve.

## Start Here

| Folder | What is in it | Notes |
| --- | --- | --- |
| `Amiga/` | Commodore Amiga tools, tutorials, source archives, and docs. | The most active part of the repo. See `Amiga/README.md`. |
| `Hardware/` | Raspberry Pi, SensorTag, Flume, Sleepia, and robotics projects. | Mixed age and polish; check each project README first. |
| `Animations/` | Animation experiments and media assets. | Large audio/video files should use Git LFS. |
| `Apple_Watch_Apps/` | Small Apple Watch experiments. | Older Xcode/watchOS projects. |
| `Web_Apps/` | Browser-based experiments and small web apps. | Project-specific setup varies. |
| `useful_scripts/` | Small shell scripts for media and file organization tasks. | See the script README before running them on important files. |
| `docs/` | Notes and reference material used by other projects. | Mostly supporting documentation. |

## Repository Notes

- This repo intentionally contains a mix of original work, historical notes, imported source archives, and external/vendor material.
- The imported material is useful context, but it may carry its own README style, license, build assumptions, and dependency history.
- For large binaries, models, PDFs, audio, and video, use Git LFS instead of regular Git tracking.
- Some older projects have vulnerable or outdated dependencies because they are preserved as historical code. Check the local README and package files before running them.

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
