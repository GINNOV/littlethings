# Amiga Sources Index

`aMiLa/amiga_sources/` is the Amiga source corpus used by the aMiLa work. It
contains Amiga-related source drops, examples,
ports, tools, libraries, and toolchains. It is not one build tree, and many
folders preserve upstream layouts.

For LLM learning or fine-tuning, start with the catalog files instead of walking
the directory blindly:

| File | Purpose |
| --- | --- |
| `_catalog/projects.tsv` | Machine-readable project inventory with category, status, and training tier. |
| `_catalog/reorganization-map.tsv` | Proposed future `git mv` layout, without moving files yet. |
| `_catalog/training-policy.md` | Inclusion, sampling, and exclusion rules for LLM data preparation. |
| `_catalog/README.md` | Category definitions and target folder taxonomy. |

## Recommended Training Order

1. **Tier 1: Curated learning material**
   Use tutorial/example folders first. They are smaller, clearer, and more likely
   to teach idiomatic Amiga concepts.

2. **Tier 2: Focused runnable projects**
   Add compact games, utilities, and demos that have a README or build file.

3. **Tier 3: Reference libraries and toolchains**
   Sample these carefully. They are valuable for APIs, compiler behavior, and
   system interfaces, but they can dominate a corpus if included wholesale.

4. **Tier 4: Large application archives and ports**
   Treat as reference-only unless the training task specifically targets that
   codebase.

5. **Exclude generated/binary/legal-sensitive material**
   Skip objects, executables, disk images, ROMs, generated parser output,
   vendored build artifacts, and license-sensitive assets unless explicitly
   cleared.

## Category Summary

| Category | Meaning |
| --- | --- |
| `learning` | Tutorials, small examples, and explanatory source. |
| `asm-demos` | Assembly effects, intros, hardware demos, and small 68k programs. |
| `c-examples` | C/C++ examples for AmigaOS APIs, hardware, or game programming. |
| `games` | Game projects and game-source recoveries. |
| `applications` | Larger applications, productivity tools, players, or ports. |
| `tools` | Host or Amiga utilities. |
| `libraries` | Reusable libraries, SDKs, NDK material, or API support code. |
| `toolchains` | Compilers, assemblers, linkers, debugger extensions, and build systems. |
| `reference` | Lists, docs, broad source dumps, or mixed reference archives. |
| `uncurated` | Material that needs inspection before ingestion. |
| `disk-assets` | Disk images, emulator config, or extracted disk material. Use only as metadata/reference unless cleared. |
| `utility-buckets` | Broad utility/source buckets that need local inspection before training. |

## Non-Destructive Reorganization

The current folder names are preserved for now. Physical moves should happen in
a separate pass using `_catalog/reorganization-map.tsv`, because many imported
projects may contain relative paths, README links, build scripts, or upstream
history that assume the current layout.
