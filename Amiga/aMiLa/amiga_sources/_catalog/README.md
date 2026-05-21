# Sources Catalog

This catalog makes `aMiLa/amiga_sources/` navigable for humans and data pipelines without
rewriting imported source trees.

## Files

| File | Consumer | Description |
| --- | --- | --- |
| `projects.tsv` | scripts, LLM pipelines, humans | Current project inventory. |
| `reorganization-map.tsv` | migration scripts, humans | Proposed physical target layout. |
| `training-policy.md` | data-prep pipeline authors | Fine-tuning and ingestion guidance. |

## Target Physical Layout

If the repository is reorganized later, use this shape:

```text
aMiLa/amiga_sources/
  learning/
  examples/
    c/
    asm/
  demos/
    asm-effects/
    intros/
  games/
  applications/
  tools/
  libraries/
  toolchains/
  reference/
  uncurated/
  disk-assets/
  utility-buckets/
```

Keep `aMiLa/amiga_sources/_catalog/` at the root. It should remain the source of truth for
LLM ingestion even after physical moves.

## Category Definitions

| Category | Use |
| --- | --- |
| `learning` | Best first-pass corpus: tutorials, simple examples, explanatory code. |
| `asm-demos` | Assembly-heavy intros, effects, hardware register demos, and snippets. |
| `c-examples` | C/C++ examples, AmigaOS API samples, game-programming examples. |
| `games` | Complete or partial game code. |
| `applications` | Larger apps, ports, players, trackers, FTP clients, and productivity tools. |
| `tools` | Utilities for development, conversion, identification, backup, or startup management. |
| `libraries` | Reusable libraries, SDKs, NDKs, API bindings, and support packages. |
| `toolchains` | Compiler, assembler, debugger, VS Code extension, and cross-build material. |
| `reference` | Broad source dumps, curated lists, docs, or mixed archives. |
| `uncurated` | Needs manual inspection before training or reorganization. |
| `disk-assets` | Disk images, emulator configs, and extracted disk material. Usually metadata-only for LLM work. |
| `utility-buckets` | Broad utility/source buckets that need inspection before inclusion. |

## Training Tiers

| Tier | Meaning |
| --- | --- |
| `1` | Preferred learning corpus. Small, focused, explanatory, or tutorial-oriented. |
| `2` | Good project corpus. Runnable or coherent, but less tutorial-like. |
| `3` | Reference corpus. Sample selectively to avoid over-weighting large/vendor code. |
| `4` | Large archive or specialized port. Use for targeted tasks only. |
| `exclude` | Skip unless a human explicitly clears it. |
