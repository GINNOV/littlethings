# Amiga Playground Tutorials

These files are **ready-to-assemble** sources for Amiga Playground.
They are fetched from this folder on app launch and cached locally.

## Adding a tutorial

1. Add a pure source file: `.s`, `.asm`, or `.c` (no Markdown).
2. Register it in `index.json` with a friendly `title` people can read.
3. Push to `master`. The app refreshes the catalog on startup.

### index.json fields

| Field | Meaning |
|-------|---------|
| `id` | Stable unique id (kebab-case) |
| `title` | Human-readable name shown in the combo |
| `summary` | Short description (optional) |
| `file` | Filename in this folder |
| `language` | `assembly` or `c` |
| `order` | Sort order (lower first) |

Files present here but missing from `index.json` still appear, using a cleaned-up file name as the title.
