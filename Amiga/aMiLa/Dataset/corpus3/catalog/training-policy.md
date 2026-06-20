# LLM Training Policy for Amiga Sources

The goal is to teach Amiga programming concepts, not to blindly maximize tokens.
Prefer coherent, licensed, explanatory source over large mixed dumps.

## Include First

Use Tier 1 folders as the base corpus:

- `amiga-asmdev-workflow`
- `amiga-assembler`
- `amiga-c`
- `amiga-c-tutorials`
- `amiga-dev`
- `amiga-examples`
- `amiga-game-prog`
- `amiga-hardware-in-c`
- `amiga-playground`
- `amiga-programming-examples`
- `amigaexamples`
- `amigaos-cpp-examples`
- `hello-ami`
- `hello-bars`
- `misc-asm-68k-amiga-ocs`
- `rainbow`
- `tutorials`
- `vhscroll`

These are useful for teaching 68k assembly basics, AmigaOS calls, hardware
registers, Copper/display concepts, and small buildable examples.

## Add Second

Use Tier 2 folders after the tutorial corpus:

- compact demos and games with clear source
- utilities with README files or Makefiles
- small self-contained AmigaOS programs

These improve breadth without overwhelming the model with large application
architecture or vendor-specific internals.

## Sample Carefully

Use Tier 3 and Tier 4 folders only when the target model or dataset needs them:

- `vasm`, `vbcc`, `m68k-amigaos-gcc`, `m68k-elf-gcc`
- `sdl`, `clib2`, `complete-ndk39`
- large applications such as `milky-tracker`, `yam`, `amiftp`, `ambermoon`
- VS Code extensions and host-side tooling

For these folders, sample README files, public headers, compact examples, and
build files before ingesting full implementation trees.

## Exclude by Default

Do not ingest these file classes without explicit review:

- binaries: `*.o`, `*.a`, `*.lib`, `*.exe`, `*.adf`, `*.lha`, `*.zip`, `*.dmg`
- generated parser/compiler output unless needed for a compiler task
- screenshots, sprites, music modules, disk images, and packed assets
- ROMs, firmware, Kickstart images, and other legal-sensitive blobs
- duplicate vendor drops when an upstream project is already represented
- build folders and cache folders
- broad disk-image or utility buckets until a human selects specific source files from them

## Preserve Attribution

Many folders are imported from upstream projects. Keep README, LICENSE,
CHANGELOG, and attribution files with every training record. If a data-prep
pipeline chunks source files, attach path, project name, license file presence,
and category from `projects.tsv`.

## Suggested Record Metadata

Each training chunk should carry:

```json
{
  "repo": "littlethings/Amiga",
  "source_path": "aMiLa/amiga_sources/<project>/<file>",
  "project": "<project>",
  "category": "<category from projects.tsv>",
  "training_tier": "<tier from projects.tsv>",
  "license_file_present": true,
  "readme_file_present": true,
  "language_hint": "m68k-asm|c|cpp|swift|typescript|mixed|docs"
}
```

## Physical Reorganization Rule

Do not move source trees further as part of data preparation. The current tree has only top-level source-folder normalization. Use
`reorganization-map.tsv` to create derived corpora outside the repo, or do a
separate reviewed `git mv` migration when build/link breakage is acceptable.
